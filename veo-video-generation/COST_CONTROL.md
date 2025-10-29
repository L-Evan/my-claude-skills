# 成本管控详细指南

## 📊 成本管控架构

### 1. 三层成本控制

```
┌─────────────────────────────────────────┐
│  Layer 1: kie.ai API 成本（外部）       │
│  - 查询余额 (GET /api/v1/chat/credit)   │
│  - 实时监控                             │
│  - 低余额预警                           │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  Layer 2: 系统级成本控制（中间层）       │
│  - 每日/每小时预算限制                   │
│  - 并发任务数限制                       │
│  - 成本预估和追踪                       │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│  Layer 3: 用户级 Credits（内部）        │
│  - 用户余额检查                         │
│  - Credits 扣除/退款                    │
│  - 使用历史记录                         │
└─────────────────────────────────────────┘
```

## 💰 成本计算和预估

### 成本模型

根据 kie.ai 实际定价（需要从控制台获取）：

```typescript
// src/lib/veo-cost.ts

interface CostConfig {
  veo3: {
    textToVideo: number;      // credits per video
    imageToVideo: number;     // credits per video
    resolution1080p: number;  // multiplier
  };
  veo3_fast: {
    textToVideo: number;
    imageToVideo: number;
    resolution1080p: number;
  };
}

// 配置实际成本（2025-01-27 确认）
const COST_CONFIG = {
  veo3_fast: {
    textToVideo: 60,          // kie.ai credits
    imageToVideo: 60,         // kie.ai credits
    usdCost: 0.30,
  },
  veo3: {
    textToVideo: 250,         // kie.ai credits (Quality mode)
    imageToVideo: 250,        // kie.ai credits
    usdCost: 1.25,
  },
  resolution1080p: {
    credits: 30,              // kie.ai credits (升级费用)
    usdCost: 0.15,
  }
};

export function estimateVideoCost(params: {
  model: 'veo3' | 'veo3_fast';
  generationType: 'TEXT_2_VIDEO' | 'FIRST_AND_LAST_FRAMES_2_VIDEO' | 'REFERENCE_2_VIDEO';
  upgrade1080p?: boolean;
}): { kieCredits: number; usdCost: number } {
  const config = COST_CONFIG[params.model];

  // 基础成本 (Text-to-Video 和 Image-to-Video 成本相同)
  let kieCredits = config.textToVideo;
  let usdCost = config.usdCost;

  // 1080p 升级费用
  if (params.upgrade1080p) {
    kieCredits += COST_CONFIG.resolution1080p.credits;
    usdCost += COST_CONFIG.resolution1080p.usdCost;
  }

  return { kieCredits, usdCost };
}
```

### 成本追踪数据库表

```sql
-- 成本追踪表
CREATE TABLE veo_cost_tracking (
  id SERIAL PRIMARY KEY,
  task_id VARCHAR(255) UNIQUE NOT NULL,
  user_id INTEGER NOT NULL,

  -- 成本预估
  estimated_cost INTEGER NOT NULL,

  -- 实际成本（回调后更新）
  actual_cost INTEGER NULL,
  cost_difference INTEGER NULL,

  -- 任务参数
  model VARCHAR(50) NOT NULL,
  generation_type VARCHAR(100) NOT NULL,
  aspect_ratio VARCHAR(20) NOT NULL,

  -- 用户 credits
  user_credits_deducted INTEGER NOT NULL,
  refunded BOOLEAN DEFAULT FALSE,

  -- kie.ai credits 快照
  kie_credits_before INTEGER NOT NULL,
  kie_credits_after INTEGER NULL,

  -- 时间戳
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP NULL,

  -- 索引
  INDEX idx_user_id (user_id),
  INDEX idx_created_at (created_at),
  INDEX idx_task_status (completed_at)
);

-- 成本统计视图
CREATE VIEW daily_cost_stats AS
SELECT
  DATE(created_at) as date,
  COUNT(*) as tasks_count,
  SUM(estimated_cost) as total_estimated,
  SUM(actual_cost) as total_actual,
  AVG(cost_difference) as avg_difference,
  SUM(CASE WHEN refunded THEN user_credits_deducted ELSE 0 END) as total_refunded
FROM veo_cost_tracking
GROUP BY DATE(created_at);
```

## 🚦 成本预警系统

### 预警等级

```typescript
// src/services/cost-alert.ts

enum AlertLevel {
  INFO = 'info',
  WARNING = 'warning',
  CRITICAL = 'critical',
  EMERGENCY = 'emergency'
}

const ALERT_THRESHOLDS = {
  kie_credits: {
    emergency: 500,    // < 500: 停止所有任务
    critical: 1000,    // < 1000: 只允许付费用户
    warning: 3000,     // < 3000: 发送预警通知
    info: 5000,        // < 5000: 记录日志
  },
  daily_cost: {
    emergency: 20000,  // 超过每日预算 200%
    critical: 15000,   // 超过每日预算 150%
    warning: 12000,    // 超过每日预算 120%
    info: 10000,       // 达到每日预算 100%
  },
  hourly_cost: {
    emergency: 2000,
    critical: 1500,
    warning: 1200,
    info: 1000,
  }
};

export async function checkCostAlerts(): Promise<Alert[]> {
  const alerts: Alert[] = [];

  // 1. 检查 kie.ai credits 余额
  const kieCredits = await getKieCreditsBalance();
  if (kieCredits < ALERT_THRESHOLDS.kie_credits.emergency) {
    alerts.push({
      level: AlertLevel.EMERGENCY,
      type: 'kie_credits_depleted',
      message: `kie.ai credits 严重不足: ${kieCredits}`,
      action: 'disable_video_generation'
    });
  }

  // 2. 检查每日成本
  const dailyCost = await getDailyCost();
  if (dailyCost > ALERT_THRESHOLDS.daily_cost.critical) {
    alerts.push({
      level: AlertLevel.CRITICAL,
      type: 'daily_budget_exceeded',
      message: `每日成本超限: ${dailyCost} / ${ALERT_THRESHOLDS.daily_cost.info}`,
      action: 'notify_admin'
    });
  }

  // 3. 检查每小时成本
  const hourlyCost = await getHourlyCost();
  if (hourlyCost > ALERT_THRESHOLDS.hourly_cost.warning) {
    alerts.push({
      level: AlertLevel.WARNING,
      type: 'hourly_spike',
      message: `每小时成本激增: ${hourlyCost}`,
      action: 'throttle_requests'
    });
  }

  return alerts;
}
```

### 自动响应机制

```typescript
// src/services/cost-protection.ts

export async function executeCostProtection(alert: Alert) {
  switch (alert.action) {
    case 'disable_video_generation':
      // 紧急停止所有视频生成
      await setSystemSetting('video_generation_enabled', false);
      await sendEmail({
        to: process.env.ADMIN_EMAIL,
        subject: '🚨 紧急：视频生成已自动停止',
        body: `kie.ai credits 余额不足，系统已自动停止视频生成。\n\n${alert.message}`
      });
      break;

    case 'notify_admin':
      await sendEmail({
        to: process.env.ADMIN_EMAIL,
        subject: `⚠️ 成本预警: ${alert.type}`,
        body: alert.message
      });
      break;

    case 'throttle_requests':
      // 限流：减少并发数
      await setSystemSetting('max_concurrent_tasks', 2);
      await sendSlackNotification({
        channel: '#alerts',
        message: `⚠️ 成本激增，已启动限流保护: ${alert.message}`
      });
      break;
  }
}
```

## 📈 成本监控 Dashboard

### API 端点

```typescript
// src/app/api/admin/cost-monitoring/route.ts

export async function GET(request: Request) {
  const auth = await authenticateAdmin(request);
  if (!auth) return Response.json({ error: 'Unauthorized' }, { status: 401 });

  const stats = {
    // kie.ai 余额
    kieCredits: {
      current: await getKieCreditsBalance(),
      threshold: ALERT_THRESHOLDS.kie_credits,
      alerts: await getCostAlerts('kie_credits')
    },

    // 今日统计
    today: {
      tasks: {
        total: await getTasksCount('today'),
        completed: await getTasksCount('today', 'completed'),
        failed: await getTasksCount('today', 'failed'),
        pending: await getTasksCount('today', 'pending')
      },
      cost: {
        estimated: await getTotalCost('today', 'estimated'),
        actual: await getTotalCost('today', 'actual'),
        difference: await getCostDifference('today'),
        refunded: await getRefundedAmount('today')
      },
      budget: {
        limit: ALERT_THRESHOLDS.daily_cost.info,
        used: await getTotalCost('today', 'estimated'),
        remaining: ALERT_THRESHOLDS.daily_cost.info - await getTotalCost('today', 'estimated'),
        percentage: (await getTotalCost('today', 'estimated') / ALERT_THRESHOLDS.daily_cost.info) * 100
      }
    },

    // 本小时统计
    thisHour: {
      tasks: await getTasksCount('hour'),
      cost: await getTotalCost('hour', 'estimated'),
      budget: {
        limit: ALERT_THRESHOLDS.hourly_cost.info,
        used: await getTotalCost('hour', 'estimated')
      }
    },

    // 本月统计
    thisMonth: {
      totalCost: await getTotalCost('month', 'actual'),
      totalTasks: await getTasksCount('month'),
      avgCostPerTask: await getAvgCostPerTask('month'),
      topUsers: await getTopUsersBySpending('month', 10)
    },

    // 活跃警报
    alerts: await getActiveCostAlerts()
  };

  return Response.json(stats);
}
```

### 前端监控界面

```tsx
// src/app/(console)/admin/cost-monitoring/page.tsx

export default function CostMonitoringPage() {
  const { data: stats } = useSWR('/api/admin/cost-monitoring', {
    refreshInterval: 60000  // 每分钟刷新
  });

  return (
    <div className="space-y-6">
      {/* 警报卡片 */}
      {stats?.alerts.length > 0 && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>成本警报 ({stats.alerts.length})</AlertTitle>
          <AlertDescription>
            {stats.alerts.map(alert => (
              <div key={alert.id}>{alert.message}</div>
            ))}
          </AlertDescription>
        </Alert>
      )}

      {/* kie.ai Credits */}
      <Card>
        <CardHeader>
          <CardTitle>kie.ai Credits 余额</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-4xl font-bold">
            {stats?.kieCredits.current.toLocaleString()}
          </div>
          <Progress
            value={(stats?.kieCredits.current / 10000) * 100}
            className="mt-4"
          />
        </CardContent>
      </Card>

      {/* 今日预算使用 */}
      <Card>
        <CardHeader>
          <CardTitle>今日预算使用</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <div className="flex justify-between">
              <span>已使用</span>
              <span className="font-bold">
                {stats?.today.budget.used} / {stats?.today.budget.limit}
              </span>
            </div>
            <Progress value={stats?.today.budget.percentage} />
            <div className="text-sm text-muted-foreground">
              剩余: {stats?.today.budget.remaining} credits
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 任务统计 */}
      <Card>
        <CardHeader>
          <CardTitle>今日任务统计</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-4 gap-4">
            <StatCard label="总计" value={stats?.today.tasks.total} />
            <StatCard label="完成" value={stats?.today.tasks.completed} color="green" />
            <StatCard label="失败" value={stats?.today.tasks.failed} color="red" />
            <StatCard label="进行中" value={stats?.today.tasks.pending} color="blue" />
          </div>
        </CardContent>
      </Card>

      {/* 成本趋势图 */}
      <Card>
        <CardHeader>
          <CardTitle>7 日成本趋势</CardTitle>
        </CardHeader>
        <CardContent>
          <CostTrendChart />
        </CardContent>
      </Card>
    </div>
  );
}
```

## 🔒 成本安全最佳实践

### 1. 预检查清单

每次视频生成前必须通过所有检查：

```typescript
async function preflightCostCheck(params: VideoGenerationParams): Promise<boolean> {
  const checks = {
    kieCreditsAvailable: false,
    userCreditsAvailable: false,
    dailyBudgetOk: false,
    hourlyBudgetOk: false,
    systemEnabled: false
  };

  // 1. kie.ai credits
  const kieCredits = await getKieCreditsBalance();
  const estimatedCost = estimateVideoCost(params);
  checks.kieCreditsAvailable = kieCredits >= estimatedCost;

  // 2. 用户 credits
  const userCredits = await getUserCredits(params.userId);
  checks.userCreditsAvailable = userCredits >= params.requiredCredits;

  // 3. 每日预算
  const dailyCost = await getDailyCost();
  checks.dailyBudgetOk = (dailyCost + estimatedCost) <= ALERT_THRESHOLDS.daily_cost.info;

  // 4. 每小时预算
  const hourlyCost = await getHourlyCost();
  checks.hourlyBudgetOk = (hourlyCost + estimatedCost) <= ALERT_THRESHOLDS.hourly_cost.info;

  // 5. 系统开关
  checks.systemEnabled = await getSystemSetting('video_generation_enabled');

  // 记录检查结果
  await logPreflightCheck({
    userId: params.userId,
    checks,
    passed: Object.values(checks).every(v => v === true)
  });

  return Object.values(checks).every(v => v === true);
}
```

### 2. 失败退款机制

```typescript
async function handleTaskFailure(taskId: string) {
  const task = await getVideoTask(taskId);

  // 1. 标记任务失败
  await updateVideoTask(taskId, { status: 'failed' });

  // 2. 退还用户 credits
  if (task.userCreditsDeducted > 0 && !task.refunded) {
    await increaseCredits(
      task.userId,
      task.userCreditsDeducted,
      'VideoGenerationRefund',
      { taskId, reason: 'generation_failed' }
    );

    await updateCostTracking(taskId, { refunded: true });
  }

  // 3. 通知用户
  await sendNotification(task.userId, {
    type: 'video_generation_failed',
    message: '视频生成失败，Credits 已退还',
    credits: task.userCreditsDeducted
  });
}
```

### 3. 定时成本审计

```typescript
// src/jobs/cost-audit.ts

// 每小时执行一次
export async function hourlyCostAudit() {
  console.log('[Cost Audit] 开始每小时成本审计...');

  // 1. 检查 kie.ai credits 余额
  const kieCredits = await getKieCreditsBalance();
  await logMetric('kie_credits_balance', kieCredits);

  // 2. 检查成本预警
  const alerts = await checkCostAlerts();
  for (const alert of alerts) {
    await executeCostProtection(alert);
  }

  // 3. 检查异常消耗
  const hourlyCost = await getHourlyCost();
  const avgHourlyCost = await getAvgHourlyCost('last_7_days');
  if (hourlyCost > avgHourlyCost * 3) {
    await sendAlert({
      level: AlertLevel.WARNING,
      message: `每小时成本异常：当前 ${hourlyCost}, 平均 ${avgHourlyCost}`
    });
  }

  // 4. 同步成本差异
  await syncCostDifferences();

  console.log('[Cost Audit] 审计完成');
}

// 每日执行一次
export async function dailyCostAudit() {
  console.log('[Cost Audit] 开始每日成本审计...');

  // 1. 生成每日报告
  const report = await generateDailyCostReport();
  await sendEmail({
    to: process.env.ADMIN_EMAIL,
    subject: `📊 每日成本报告 - ${new Date().toLocaleDateString()}`,
    body: formatCostReport(report)
  });

  // 2. 检查未完成任务
  const pendingTasks = await getPendingTasks('older_than_24h');
  if (pendingTasks.length > 0) {
    await sendAlert({
      level: AlertLevel.WARNING,
      message: `发现 ${pendingTasks.length} 个超过 24 小时未完成的任务`
    });
  }

  // 3. 清理过期数据
  await cleanupOldCostRecords('older_than_90_days');

  console.log('[Cost Audit] 审计完成');
}
```

## 📋 成本管控检查清单

### 部署前检查

- [ ] 配置 `KIE_AI_API_KEY`
- [ ] 设置成本阈值 (`COST_THRESHOLDS`)
- [ ] 配置预警邮箱 (`ADMIN_EMAIL`)
- [ ] 创建成本追踪数据库表
- [ ] 部署成本监控 Dashboard
- [ ] 设置定时审计任务（cron）
- [ ] 测试失败退款流程
- [ ] 测试成本预警机制

### 运营期间检查（每日）

- [ ] 查看成本监控 Dashboard
- [ ] 检查 kie.ai credits 余额
- [ ] 审查成本预估 vs 实际差异
- [ ] 检查是否有大额异常消耗
- [ ] 确认退款是否正常执行
- [ ] 审查失败率和原因

### 月度审查

- [ ] 生成月度成本报告
- [ ] 分析成本趋势
- [ ] 优化成本模型（调整预估系数）
- [ ] 评估是否需要调整预算限制
- [ ] 审查 Top 10 消耗用户

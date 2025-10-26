---
name: veo-video-generation
description: Veo 3 视频生成服务集成和成本管控。Use when implementing video generation, managing credits, cost control, handling video callbacks, or when user mentions veo, video generation, AI video, cost budget.
---

# Veo Video Generation & Cost Control Skill

处理 Veo 3 AI 视频生成的完整流程，包含**实时成本管控**和 kie.ai API 对接。

## When to Use This Skill

- 实现视频生成功能
- 调试 Veo API 对接
- **成本管控和预算校验**
- Credits 余额管理
- 处理视频回调和状态
- User mentions: "视频生成", "veo", "AI video", "成本", "credits", "cost control"

## 🔑 核心流程：成本管控优先

### Step 1: 成本预检查（必须先执行）

**在每次视频生成前，必须先检查成本！**

```typescript
// 1. 检查 kie.ai 账户余额
const kieCredits = await fetch('https://api.kie.ai/api/v1/chat/credit', {
  headers: {
    'Authorization': `Bearer ${process.env.KIE_AI_API_KEY}`,
  }
});
const { data: remainingCredits } = await kieCredits.json();

// 2. 检查用户本地 Credits
const userCredits = await getUserCredits(userId);

// 3. 预估本次生成成本
const estimatedCost = calculateVideoCost({
  model: 'veo3',  // veo3 or veo3_fast
  resolution: '1080p',
  duration: 5  // seconds
});

// 4. 成本校验
if (remainingCredits < estimatedCost) {
  throw new Error(`kie.ai credits 不足: 需要 ${estimatedCost}, 余额 ${remainingCredits}`);
}

if (userCredits < REQUIRED_USER_CREDITS) {
  throw new Error(`用户 credits 不足: 需要 ${REQUIRED_USER_CREDITS}, 余额 ${userCredits}`);
}

// 5. 记录成本预估
await logCostEstimate({
  userId,
  taskType: 'veo3_video',
  estimatedCost,
  kieCreditsBalance: remainingCredits,
  userCreditsBalance: userCredits
});
```

**成本检查清单** - 见 [COST_CONTROL.md](COST_CONTROL.md)

### Step 2: 调用 Veo 3 API

```typescript
// 生成请求
const response = await fetch('https://api.kie.ai/api/v1/veo/generate', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${process.env.KIE_AI_API_KEY}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    prompt: userPrompt,
    model: 'veo3',  // 或 'veo3_fast' 更便宜
    aspectRatio: '16:9',  // 9:16, Auto
    generationType: 'TEXT_2_VIDEO',  // FIRST_AND_LAST_FRAMES_2_VIDEO, REFERENCE_2_VIDEO
    callBackUrl: `${process.env.APP_URL}/api/veo/callback`,
    seeds: Math.floor(Math.random() * 90000) + 10000,
    enableTranslation: true
  })
});

const { code, msg, data } = await response.json();

if (code !== 200) {
  throw new Error(`Veo API Error: ${msg}`);
}

const { taskId } = data;
```

**错误处理** - 见 [references/error-codes.md](references/error-codes.md)

### Step 3: 扣除用户 Credits

```typescript
// 扣除用户 credits（记录 taskId 用于失败退款）
await decreaseCredits(userId, REQUIRED_USER_CREDITS, 'VideoGeneration', {
  taskId,
  model: 'veo3',
  prompt: userPrompt
});
```

### Step 4: 保存任务记录

```typescript
// 保存任务到数据库（用于成本追踪）
await saveVideoTask({
  taskId,
  userId,
  prompt: userPrompt,
  model: 'veo3',
  estimatedCost,
  userCreditsDeducted: REQUIRED_USER_CREDITS,
  status: 'pending',
  createdAt: new Date()
});
```

### Step 5: 处理回调（成本确认）

```typescript
// Webhook: /api/veo/callback
app.post('/api/veo/callback', async (req, res) => {
  const { taskId, status, videoUrl } = req.body;

  // 1. 更新任务状态
  const task = await updateVideoTask(taskId, {
    status,
    videoUrl,
    completedAt: new Date()
  });

  // 2. 查询实际消耗的成本
  const actualCost = await getActualCost(taskId);

  // 3. 记录成本差异
  await logCostDifference({
    taskId,
    estimatedCost: task.estimatedCost,
    actualCost,
    difference: actualCost - task.estimatedCost
  });

  // 4. 如果失败，退还用户 credits
  if (status === 'failed') {
    await increaseCredits(
      task.userId,
      task.userCreditsDeducted,
      'VideoGenerationRefund',
      { taskId }
    );
  }

  res.json({ code: 200, msg: 'success' });
});
```

## 💰 成本管控策略

### 成本计算公式

```typescript
function calculateVideoCost(params: {
  model: 'veo3' | 'veo3_fast';
  resolution: '1080p' | '720p';
  duration: number;
}) {
  const baseCost = {
    'veo3': 100,      // 基础成本（假设）
    'veo3_fast': 50   // 快速模式更便宜
  };

  const resolutionMultiplier = {
    '1080p': 1.5,
    '720p': 1.0
  };

  return baseCost[params.model] *
         resolutionMultiplier[params.resolution] *
         (params.duration / 5);  // 假设 5 秒为基准
}
```

### 成本预警阈值

```typescript
const COST_THRESHOLDS = {
  LOW_BALANCE: 1000,      // kie.ai credits < 1000 发送预警
  CRITICAL_BALANCE: 500,  // < 500 停止新任务
  DAILY_LIMIT: 10000,     // 每日最大消耗
  HOURLY_LIMIT: 1000      // 每小时最大消耗
};
```

### 成本监控 Dashboard

创建成本监控端点：

```typescript
// GET /api/admin/cost-monitoring
app.get('/api/admin/cost-monitoring', async (req, res) => {
  const stats = {
    kieCreditsBalance: await getKieCreditsBalance(),
    today: {
      tasksCount: await getTasksCount('today'),
      estimatedCost: await getTotalCost('today'),
      actualCost: await getActualTotalCost('today')
    },
    thisHour: {
      tasksCount: await getTasksCount('hour'),
      estimatedCost: await getTotalCost('hour')
    },
    alerts: await getCostAlerts()
  };

  res.json(stats);
});
```

## 🚨 错误处理和成本安全

### 关键错误码处理

```typescript
switch (errorCode) {
  case 402:
    // kie.ai credits 不足
    await sendAlert('CRITICAL: kie.ai credits 不足！');
    await disableVideoGeneration();
    break;

  case 429:
    // Rate limit - 不扣费，稍后重试
    await scheduleRetry(taskId, delayMinutes: 1);
    break;

  case 501:
    // 生成失败 - 退还 credits
    await refundUserCredits(taskId);
    break;
}
```

### 成本防护措施

1. **双重检查**：调用前检查 kie.ai + 用户 credits
2. **失败退款**：生成失败自动退还用户 credits
3. **成本追踪**：每次请求记录预估和实际成本
4. **预算限制**：设置每日/每小时/每用户限额
5. **实时监控**：低余额自动告警

## 📚 Reference Files

- `COST_CONTROL.md` - 成本管控详细指南
- `references/api.md` - Veo API 完整文档
- `references/error-codes.md` - 错误码说明
- `scripts/check-credits.sh` - Credits 检查脚本
- `scripts/cost-report.sh` - 成本报告生成

## ⚙️ 环境变量配置

```env
# kie.ai API
KIE_AI_API_KEY=your_api_key_here
KIE_AI_BASE_URL=https://api.kie.ai

# 成本管控
COST_ALERT_EMAIL=admin@example.com
DAILY_COST_LIMIT=10000
HOURLY_COST_LIMIT=1000
LOW_BALANCE_THRESHOLD=1000
```

## 📊 成本监控清单

定期检查（每日）：
- [ ] kie.ai credits 余额是否充足
- [ ] 昨日实际消耗 vs 预估差异
- [ ] 是否有异常大额消耗
- [ ] 用户 credits 使用趋势
- [ ] 失败退款是否正常执行

## Important Notes

- **成本优先**：永远先检查成本再调用 API
- **异步处理**：视频生成需要 2-5 分钟，使用 callback
- **失败退款**：确保失败时正确退还 credits
- **并发限制**：控制并发数避免成本失控
- **模型选择**：`veo3_fast` 成本更低，适合预览

## Next Steps

1. 配置 kie.ai API Key
2. 设置成本监控 Dashboard
3. 配置成本预警邮件
4. 测试完整流程（包含失败场景）
5. 部署到生产环境

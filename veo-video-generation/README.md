# Veo Video Generation Skill - 使用指南

## 📁 Skill 文件结构

```
.claude/skills/veo-video-generation/
├── SKILL.md                      # 核心文档（Claude 读取）
├── COST_CONTROL.md               # 成本管控详细指南
├── API_RATE_LIMITING.md          # 接口管控和限流
├── README.md                     # 本文件
├── references/
│   ├── api.md                    # Veo API 完整参考
│   └── pricing.md                # kie.ai 价格映射表
└── scripts/
    └── check-credits.sh          # Credits 余额检查脚本
```

## 🚀 快速开始

### 1. 配置环境变量

```bash
# .env.local 或 .env.production

# kie.ai API
KIE_AI_API_KEY=your_api_key_here
KIE_AI_BASE_URL=https://api.kie.ai

# 成本管控
DAILY_COST_LIMIT=10000
HOURLY_COST_LIMIT=1000
LOW_BALANCE_THRESHOLD=1000

# 告警配置
ALERT_EMAIL=admin@example.com

# Redis（限流用）
REDIS_URL=redis://localhost:6379
```

### 2. 测试 Credits 检查

```bash
# 导出 API Key
export KIE_AI_API_KEY=your_api_key

# 运行检查脚本
.claude/skills/veo-video-generation/scripts/check-credits.sh

# 输出 JSON 格式
.claude/skills/veo-video-generation/scripts/check-credits.sh --json
```

### 3. 设置定时检查（可选）

```bash
# 添加到 crontab，每小时检查一次
crontab -e

# 添加以下行：
0 * * * * cd /path/to/project && KIE_AI_API_KEY=xxx .claude/skills/veo-video-generation/scripts/check-credits.sh >> /var/log/veo-credits.log 2>&1
```

## 📖 核心功能

### 1. 成本管控

**三层成本控制体系：**
1. kie.ai API 成本（外部）
2. 系统级成本控制（预算限制）
3. 用户级 Credits（内部计费）

详见：[COST_CONTROL.md](COST_CONTROL.md)

**关键特性：**
- ✅ 生成前成本预检查
- ✅ 实时余额监控
- ✅ 失败自动退款
- ✅ 成本追踪和报告
- ✅ 预算超限自动熔断

### 2. 接口管控

**四层限流体系：**
1. 外部 API 限流（kie.ai）
2. 全局并发控制
3. 用户级配额限制
4. IP 级防滥用

详见：[API_RATE_LIMITING.md](API_RATE_LIMITING.md)

**关键特性：**
- ✅ 全局并发数控制
- ✅ 用户分级限流（Free/Pro/Enterprise）
- ✅ 指数退避重试（429 错误）
- ✅ 实时限流监控
- ✅ 队列管理

### 3. API 集成

完整的 Veo 3.1 API 对接文档。

详见：[references/api.md](references/api.md)

**支持的功能：**
- ✅ Text-to-Video
- ✅ Image-to-Video（单图/首尾帧）
- ✅ 双模式（Fast/Quality）
- ✅ 自定义分辨率
- ✅ Webhook 回调

### 4. 价格管理

详细的成本计算和定价策略。

详见：[references/pricing.md](references/pricing.md)

**价格信息：**
- Veo 3.1 Fast: 20 kie.ai credits ($0.10)
- Veo 3.1 Quality: 150 kie.ai credits ($0.75)
- 1000 credits = $5.00

## 💡 使用场景

### 场景 1: 实现视频生成功能

```typescript
import { veoAPIClient } from '@/lib/veo-api-client';
import { checkCostAvailability } from '@/lib/cost-control';
import { globalLimiter } from '@/lib/rate-limiter';

async function generateVideo(params) {
  // 1. 成本检查
  const costCheck = await checkCostAvailability({
    userId: params.userId,
    model: 'veo3_fast',
    generationType: 'TEXT_2_VIDEO',
    aspectRatio: '16:9'
  });

  if (!costCheck.allowed) {
    throw new Error('Insufficient credits');
  }

  // 2. 全局并发控制
  return await globalLimiter.acquire(async () => {
    // 3. 调用 API
    const { taskId } = await veoAPIClient.generateVideo({
      prompt: params.prompt,
      model: 'veo3_fast',
      callBackUrl: `${process.env.APP_URL}/api/veo/callback`
    });

    // 4. 扣除 credits
    await deductUserCredits(params.userId, costCheck.required, taskId);

    return { taskId };
  });
}
```

### 场景 2: 监控成本

```bash
# 手动检查
./scripts/check-credits.sh

# 集成到监控系统
./scripts/check-credits.sh --json | jq .

# 示例输出：
{
  "credits": 15420,
  "usdValue": 77.10,
  "status": "INFO",
  "canGenerate": {
    "fast": 771,
    "quality": 102
  }
}
```

### 场景 3: 处理限流

```typescript
import { userRateLimiter } from '@/lib/user-rate-limiter';

async function handleVideoRequest(userId, userTier) {
  // 检查限流
  const rateLimitCheck = await userRateLimiter.checkLimit(userId, userTier);

  if (!rateLimitCheck.allowed) {
    return Response.json({
      error: 'RATE_LIMIT_EXCEEDED',
      reason: rateLimitCheck.reason,
      retryAfter: rateLimitCheck.retryAfter
    }, { status: 429 });
  }

  // 处理请求...
}
```

## 🔍 常见问题

### Q: 如何触发这个 skill？

A: Claude 会在以下情况自动使用这个 skill：
- 提到 "veo", "视频生成", "AI video"
- 讨论 "成本管控", "credits", "cost control"
- 实现视频生成功能时

你也可以直接说："使用 veo-video-generation skill"

### Q: 成本预估准确吗？

A: 成本预估基于官方价格：
- Fast: 20 credits = $0.10
- Quality: 150 credits = $0.75

实际消耗应该与预估一致。建议定期对比实际成本。

### Q: 如何设置成本预警？

A: 三种方式：

1. **脚本检查**（推荐）
```bash
./scripts/check-credits.sh
```

2. **定时任务**
```bash
# crontab
0 * * * * /path/to/check-credits.sh
```

3. **应用内监控**
```typescript
// 每小时检查一次
setInterval(async () => {
  const credits = await getKieCreditsBalance();
  if (credits < 1000) {
    await sendAlert('Credits 不足');
  }
}, 3600000);
```

### Q: 如何处理生成失败？

A: 自动退款机制：

```typescript
// Webhook 回调处理
if (successFlag !== 1) {
  // 退还用户 credits
  await increaseCredits(
    task.userId,
    task.userCreditsDeducted,
    'VideoGenerationRefund',
    { taskId }
  );
}
```

### Q: 支持哪些视频模式？

A: 三种模式：
1. **TEXT_2_VIDEO**: 纯文本生成
2. **REFERENCE_2_VIDEO**: 单图参考
3. **FIRST_AND_LAST_FRAMES_2_VIDEO**: 首尾帧插值

详见：[references/api.md](references/api.md)

## 📊 监控指标

### 成本监控

- kie.ai credits 余额
- 每日/每小时消耗
- 实际成本 vs 预估差异
- 失败率和退款金额

### 性能监控

- API 成功率
- 平均响应时间
- 生成完成时间
- 失败原因分布

### 限流监控

- 全局并发负载
- 用户限流触发次数
- 429 错误频率
- 队列深度

## 🛠️ 下一步

1. **配置环境**
   - 设置 `KIE_AI_API_KEY`
   - 配置成本阈值
   - 设置 Redis（限流用）

2. **实现核心功能**
   - 视频生成 API 端点
   - Webhook 回调处理
   - 成本追踪数据库

3. **部署监控**
   - 成本监控 Dashboard
   - 定时 credits 检查
   - 告警通知配置

4. **测试**
   - 完整生成流程
   - 失败退款机制
   - 限流保护

## 📚 相关资源

- [kie.ai 官方文档](https://docs.kie.ai/)
- [kie.ai API Key 管理](https://kie.ai/api-key)
- [CLAUDE.md](../../CLAUDE.md) - 项目总体文档

## 🤝 贡献

如果你发现价格变化或 API 更新，请更新：
- `references/pricing.md` - 价格信息
- `references/api.md` - API 文档

---

**创建日期**: 2025-01-26
**最后更新**: 2025-01-26
**维护者**: 项目团队

# Veo 3.1 API 参考文档

基于 kie.ai 官方文档整理。

## 🔗 API 端点

### Base URL
```
https://api.kie.ai
```

### 认证
所有请求需要在 Header 中包含：
```
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

获取 API Key: https://kie.ai/api-key

---

## 📹 视频生成 API

### POST /api/v1/veo/generate

生成 AI 视频。

#### 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `prompt` | string | ✅ | 视频描述文本（详细描述效果更好） |
| `model` | string | ❌ | `veo3` (高质量) 或 `veo3_fast` (快速，默认) |
| `generationType` | string | ❌ | 生成类型，见下方说明 |
| `imageUrls` | array | ❌ | 1-2 张图片 URL（image-to-video 模式） |
| `aspectRatio` | string | ❌ | `16:9`(默认，支持1080p), `9:16`, `Auto` |
| `seeds` | integer | ❌ | 随机种子 (10000-99999)，用于复现结果 |
| `callBackUrl` | string | ❌ | 回调 URL，生成完成后通知 |
| `enableTranslation` | boolean | ❌ | 自动翻译 prompt 为英文（默认 true） |
| `watermark` | string | ❌ | 水印文本 |

#### generationType 类型

| 值 | 说明 | 需要 imageUrls |
|---|------|---------------|
| `TEXT_2_VIDEO` | 文本生成视频（默认） | ❌ |
| `FIRST_AND_LAST_FRAMES_2_VIDEO` | 首尾帧生成视频 | ✅ (2张) |
| `REFERENCE_2_VIDEO` | 参考图生成视频 | ✅ (1张) |

#### 请求示例

```bash
curl -X POST https://api.kie.ai/api/v1/veo/generate \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "A golden retriever playing with a ball in a sunny park, slow motion, cinematic lighting",
    "model": "veo3_fast",
    "aspectRatio": "16:9",
    "callBackUrl": "https://your-domain.com/api/veo/callback"
  }'
```

#### 成功响应

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "taskId": "veo_task_1234567890abcdef"
  }
}
```

#### 错误码

| Code | 说明 | 处理方式 |
|------|------|----------|
| 400 | 1080P 处理中 | 等待 1-2 分钟后重试 |
| 401 | 认证失败 | 检查 API Key |
| 402 | **kie.ai credits 不足** | 充值或停止服务 |
| 404 | 资源不存在 | 检查 URL |
| 422 | 参数验证失败 | 检查请求参数 |
| 429 | **请求过于频繁** | 指数退避重试 |
| 455 | 服务维护中 | 稍后重试 |
| 500 | 服务器错误 | 重试或联系支持 |
| 501 | **生成失败** | 需退还用户 credits |
| 505 | 功能已禁用 | - |

---

## 🔍 查询视频状态 API

### GET /api/v1/veo/query/{taskId}

查询视频生成状态。

#### 请求示例

```bash
curl -X GET "https://api.kie.ai/api/v1/veo/query/veo_task_1234567890abcdef" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

#### 响应示例

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "taskId": "veo_task_1234567890abcdef",
    "successFlag": 1,
    "videoUrl": "https://cdn.kie.ai/videos/xxx.mp4",
    "createdAt": "2025-01-15T10:30:00Z",
    "completedAt": "2025-01-15T10:33:45Z"
  }
}
```

#### successFlag 状态

| 值 | 状态 | 说明 |
|---|------|------|
| 0 | 处理中 | 继续轮询（建议间隔 10 秒） |
| 1 | 成功 | 可获取 videoUrl |
| 2 | 失败 | 需退还用户 credits |
| 3 | 失败 | 需退还用户 credits |

---

## 💰 查询余额 API

### GET /api/v1/chat/credit

查询 kie.ai 账户剩余 credits。

#### 请求示例

```bash
curl -X GET https://api.kie.ai/api/v1/chat/credit \
  -H "Authorization: Bearer YOUR_API_KEY"
```

#### 响应示例

```json
{
  "code": 200,
  "msg": "success",
  "data": 15420
}
```

`data` 字段为剩余 credits 数量。

---

## 📞 Webhook 回调

### 回调格式

当视频生成完成时，kie.ai 会向 `callBackUrl` 发送 POST 请求：

```json
{
  "taskId": "veo_task_1234567890abcdef",
  "successFlag": 1,
  "videoUrl": "https://cdn.kie.ai/videos/xxx.mp4",
  "createdAt": "2025-01-15T10:30:00Z",
  "completedAt": "2025-01-15T10:33:45Z"
}
```

### 回调处理示例

```typescript
// src/app/api/veo/callback/route.ts

export async function POST(request: Request) {
  const body = await request.json();
  const { taskId, successFlag, videoUrl } = body;

  // 1. 查询任务记录
  const task = await getVideoTask(taskId);
  if (!task) {
    return Response.json({ error: 'Task not found' }, { status: 404 });
  }

  // 2. 更新任务状态
  await updateVideoTask(taskId, {
    status: successFlag === 1 ? 'completed' : 'failed',
    videoUrl: successFlag === 1 ? videoUrl : null,
    completedAt: new Date()
  });

  // 3. 处理成功/失败
  if (successFlag === 1) {
    // 成功：通知用户
    await notifyUser(task.userId, {
      type: 'video_ready',
      taskId,
      videoUrl
    });

    // 释放用户并发槽位
    await userRateLimiter.releaseConcurrent(task.userId);
  } else {
    // 失败：退还 credits
    await handleTaskFailure(taskId);
  }

  // 4. 记录实际成本
  const actualCost = await getActualCostFromKieAI(taskId);
  await updateCostTracking(taskId, { actualCost });

  return Response.json({ success: true });
}
```

---

## ⏱️ 性能指标

### 视频生成时间

| 模型 | 平均时间 | 说明 |
|------|---------|------|
| `veo3_fast` | 2-3 分钟 | 快速模式 |
| `veo3` | 3-5 分钟 | 高质量模式 |

**注意**：1080P 视频可能需要额外 1-2 分钟处理时间。

### 建议

1. **使用 callback 而非轮询**
   - 轮询建议间隔 ≥ 10 秒
   - Callback 更高效

2. **及时下载视频**
   - kie.ai 的 videoUrl 有效期未知
   - 建议立即下载并存储到自己的 CDN

3. **错误处理**
   - 实现指数退避重试（429 错误）
   - 失败时退还用户 credits
   - 记录所有错误日志

---

## 🎯 最佳实践

### Prompt 优化

好的 prompt 示例：
```
A majestic eagle soaring through a cloudy sky at sunset,
slow motion, cinematic lighting, 4k quality, golden hour
```

差的 prompt 示例：
```
eagle
```

**建议**：
- 详细描述场景、动作、风格
- 包含镜头运动（slow motion, pan, zoom）
- 指定光线和氛围
- 英文 prompt 效果更好（或启用自动翻译）

### 模型选择

| 场景 | 推荐模型 | 原因 |
|------|---------|------|
| 预览/测试 | `veo3_fast` | 便宜快速 |
| 正式发布 | `veo3` | 高质量 |
| 成本敏感 | `veo3_fast` | 成本仅为 veo3 的 13% |

### 成本优化

1. **默认使用 veo3_fast**
   - 让用户选择是否升级到 veo3
   - Fast 模式成本 $0.10，Quality 模式 $0.75

2. **批量生成优化**
   - 控制并发数避免大量失败
   - 失败重试前检查余额

3. **缓存相似 prompt**
   - 相同 prompt + seeds 可复现结果
   - 避免重复生成相同内容

---

## 🔐 安全建议

1. **API Key 管理**
   - 不要在前端暴露 API Key
   - 定期轮换 API Key
   - 使用环境变量存储

2. **请求验证**
   - 验证用户权限
   - 检查 prompt 内容合规
   - 限制请求频率

3. **成本保护**
   - 设置每日/每月预算上限
   - 低余额自动告警
   - 异常消耗自动熔断

---

## 📚 相关文档

- [COST_CONTROL.md](../COST_CONTROL.md) - 成本管控详细指南
- [API_RATE_LIMITING.md](../API_RATE_LIMITING.md) - 接口管控和限流
- [pricing.md](./pricing.md) - kie.ai 价格映射表
- [error-codes.md](./error-codes.md) - 错误码详细说明

---

## 🐛 常见问题

### Q: 视频生成失败率高怎么办？

A: 检查以下几点：
1. Prompt 是否违反内容政策
2. ImageUrls 是否可访问（HTTPS, 无需认证）
3. kie.ai credits 是否充足
4. 网络连接是否稳定

### Q: 如何处理 429 Rate Limit？

A: 实现指数退避重试：
```typescript
const delays = [1s, 2s, 4s, 8s, 16s, 32s];
for (let i = 0; i < delays.length; i++) {
  try {
    return await callAPI();
  } catch (error) {
    if (error.code !== 429) throw error;
    await sleep(delays[i]);
  }
}
```

### Q: videoUrl 有效期多久？

A: 官方文档未明确说明。建议**立即下载**视频到自己的存储。

### Q: 1080P 视频需要额外操作吗？

A: 16:9 视频默认支持 1080P，但可能需要额外 1-2 分钟处理。如果收到 400 错误，等待后重新查询即可。

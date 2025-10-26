# 接口管控详细指南

## 🎯 接口管控架构

### 四层管控体系

```
┌────────────────────────────────────────────────┐
│  Layer 1: 外部 API 限流 (kie.ai)                │
│  - HTTP 429: Rate limit exceeded                │
│  - 需要实现指数退避重试                          │
│  - 动态调整请求速率                             │
└────────────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────────────┐
│  Layer 2: 系统级限流 (Application)              │
│  - 全局并发数限制                               │
│  - 每秒/每分钟请求数 (QPS/QPM)                   │
│  - 队列管理                                     │
└────────────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────────────┐
│  Layer 3: 用户级限流 (Per User)                 │
│  - 单用户并发限制                               │
│  - 单用户每日配额                               │
│  - 付费/免费用户分级                            │
└────────────────────────────────────────────────┘
              ↓
┌────────────────────────────────────────────────┐
│  Layer 4: IP 级防滥用 (Anti-Abuse)              │
│  - IP 请求频率限制                              │
│  - 异常行为检测                                 │
│  - 黑名单/白名单                                │
└────────────────────────────────────────────────┘
```

## 🚦 限流策略实现

### 1. 全局并发控制

使用信号量控制同时进行的视频生成任务数：

```typescript
// src/lib/rate-limiter.ts

class GlobalConcurrencyLimiter {
  private maxConcurrent: number;
  private currentTasks: number = 0;
  private queue: Array<() => Promise<void>> = [];

  constructor(maxConcurrent: number = 10) {
    this.maxConcurrent = maxConcurrent;
  }

  async acquire<T>(fn: () => Promise<T>): Promise<T> {
    // 等待直到有可用槽位
    while (this.currentTasks >= this.maxConcurrent) {
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    this.currentTasks++;

    try {
      const result = await fn();
      return result;
    } finally {
      this.currentTasks--;
      this.processQueue();
    }
  }

  private processQueue() {
    if (this.queue.length > 0 && this.currentTasks < this.maxConcurrent) {
      const next = this.queue.shift();
      if (next) next();
    }
  }

  getCurrentLoad(): number {
    return this.currentTasks / this.maxConcurrent;
  }

  getStats() {
    return {
      current: this.currentTasks,
      max: this.maxConcurrent,
      queued: this.queue.length,
      loadPercentage: (this.currentTasks / this.maxConcurrent) * 100
    };
  }
}

export const globalLimiter = new GlobalConcurrencyLimiter(10);
```

### 2. 用户级限流（Redis 实现）

```typescript
// src/lib/user-rate-limiter.ts

import { Redis } from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

interface RateLimitConfig {
  maxConcurrent: number;   // 单用户最大并发数
  dailyQuota: number;      // 每日配额
  hourlyQuota: number;     // 每小时配额
  minuteQuota: number;     // 每分钟配额
}

const RATE_LIMITS: Record<string, RateLimitConfig> = {
  free: {
    maxConcurrent: 1,
    dailyQuota: 10,
    hourlyQuota: 5,
    minuteQuota: 2
  },
  pro: {
    maxConcurrent: 3,
    dailyQuota: 100,
    hourlyQuota: 20,
    minuteQuota: 5
  },
  enterprise: {
    maxConcurrent: 10,
    dailyQuota: 1000,
    hourlyQuota: 100,
    minuteQuota: 20
  }
};

export class UserRateLimiter {
  async checkLimit(userId: number, userTier: 'free' | 'pro' | 'enterprise'): Promise<{
    allowed: boolean;
    reason?: string;
    retryAfter?: number;
  }> {
    const config = RATE_LIMITS[userTier];
    const now = Date.now();

    // 1. 检查并发数
    const concurrentKey = `concurrent:${userId}`;
    const concurrent = await redis.get(concurrentKey);
    if (concurrent && parseInt(concurrent) >= config.maxConcurrent) {
      return {
        allowed: false,
        reason: 'MAX_CONCURRENT_REACHED',
        retryAfter: 60
      };
    }

    // 2. 检查每分钟配额
    const minuteKey = `quota:minute:${userId}:${Math.floor(now / 60000)}`;
    const minuteCount = await redis.incr(minuteKey);
    await redis.expire(minuteKey, 60);
    if (minuteCount > config.minuteQuota) {
      return {
        allowed: false,
        reason: 'MINUTE_QUOTA_EXCEEDED',
        retryAfter: 60 - (now % 60000) / 1000
      };
    }

    // 3. 检查每小时配额
    const hourKey = `quota:hour:${userId}:${Math.floor(now / 3600000)}`;
    const hourCount = await redis.incr(hourKey);
    await redis.expire(hourKey, 3600);
    if (hourCount > config.hourlyQuota) {
      return {
        allowed: false,
        reason: 'HOURLY_QUOTA_EXCEEDED',
        retryAfter: 3600 - (now % 3600000) / 1000
      };
    }

    // 4. 检查每日配额
    const today = new Date().toISOString().split('T')[0];
    const dailyKey = `quota:daily:${userId}:${today}`;
    const dailyCount = await redis.incr(dailyKey);
    await redis.expire(dailyKey, 86400);
    if (dailyCount > config.dailyQuota) {
      return {
        allowed: false,
        reason: 'DAILY_QUOTA_EXCEEDED',
        retryAfter: 86400 - (now % 86400000) / 1000
      };
    }

    // 5. 通过所有检查，增加并发计数
    await redis.incr(concurrentKey);
    await redis.expire(concurrentKey, 3600);

    return { allowed: true };
  }

  async releaseConcurrent(userId: number) {
    const concurrentKey = `concurrent:${userId}`;
    await redis.decr(concurrentKey);
  }

  async getUserQuotaStatus(userId: number, userTier: 'free' | 'pro' | 'enterprise') {
    const config = RATE_LIMITS[userTier];
    const now = Date.now();
    const today = new Date().toISOString().split('T')[0];

    const [concurrent, minuteCount, hourCount, dailyCount] = await Promise.all([
      redis.get(`concurrent:${userId}`),
      redis.get(`quota:minute:${userId}:${Math.floor(now / 60000)}`),
      redis.get(`quota:hour:${userId}:${Math.floor(now / 3600000)}`),
      redis.get(`quota:daily:${userId}:${today}`)
    ]);

    return {
      concurrent: {
        current: parseInt(concurrent || '0'),
        max: config.maxConcurrent
      },
      minute: {
        used: parseInt(minuteCount || '0'),
        limit: config.minuteQuota,
        remaining: config.minuteQuota - parseInt(minuteCount || '0')
      },
      hour: {
        used: parseInt(hourCount || '0'),
        limit: config.hourlyQuota,
        remaining: config.hourlyQuota - parseInt(hourCount || '0')
      },
      daily: {
        used: parseInt(dailyCount || '0'),
        limit: config.dailyQuota,
        remaining: config.dailyQuota - parseInt(dailyCount || '0')
      }
    };
  }
}

export const userRateLimiter = new UserRateLimiter();
```

### 3. kie.ai API 重试策略（指数退避）

处理 kie.ai 的 429 Rate Limit 错误：

```typescript
// src/lib/veo-api-client.ts

interface RetryConfig {
  maxRetries: number;
  baseDelay: number;      // 基础延迟（毫秒）
  maxDelay: number;       // 最大延迟（毫秒）
  backoffMultiplier: number;
}

const RETRY_CONFIG: RetryConfig = {
  maxRetries: 5,
  baseDelay: 1000,        // 1 秒
  maxDelay: 32000,        // 32 秒
  backoffMultiplier: 2
};

export class VeoAPIClient {
  private async callWithRetry<T>(
    fn: () => Promise<T>,
    retryCount: number = 0
  ): Promise<T> {
    try {
      return await fn();
    } catch (error: any) {
      // 检查是否是可重试的错误
      if (!this.isRetryableError(error) || retryCount >= RETRY_CONFIG.maxRetries) {
        throw error;
      }

      // 计算退避延迟
      const delay = Math.min(
        RETRY_CONFIG.baseDelay * Math.pow(RETRY_CONFIG.backoffMultiplier, retryCount),
        RETRY_CONFIG.maxDelay
      );

      // 添加随机抖动（±25%）
      const jitter = delay * 0.25 * (Math.random() * 2 - 1);
      const finalDelay = delay + jitter;

      console.log(`[VeoAPI] Retry ${retryCount + 1}/${RETRY_CONFIG.maxRetries} after ${Math.round(finalDelay)}ms, error: ${error.message}`);

      // 记录重试
      await this.logRetry({
        attempt: retryCount + 1,
        errorCode: error.code,
        delay: finalDelay
      });

      // 等待后重试
      await new Promise(resolve => setTimeout(resolve, finalDelay));
      return this.callWithRetry(fn, retryCount + 1);
    }
  }

  private isRetryableError(error: any): boolean {
    // 可重试的错误码
    const retryableStatusCodes = [
      429,  // Rate limit
      500,  // Server error
      502,  // Bad gateway
      503,  // Service unavailable
      504,  // Gateway timeout
    ];

    return retryableStatusCodes.includes(error.code || error.status);
  }

  async generateVideo(params: VideoGenerationParams): Promise<{ taskId: string }> {
    return this.callWithRetry(async () => {
      const response = await fetch('https://api.kie.ai/api/v1/veo/generate', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.KIE_AI_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(params)
      });

      if (!response.ok) {
        const error: any = new Error(`API Error: ${response.status}`);
        error.status = response.status;
        error.code = response.status;
        throw error;
      }

      const data = await response.json();
      if (data.code !== 200) {
        const error: any = new Error(data.msg);
        error.code = data.code;
        throw error;
      }

      return data.data;
    });
  }

  async getCreditsBalance(): Promise<number> {
    return this.callWithRetry(async () => {
      const response = await fetch('https://api.kie.ai/api/v1/chat/credit', {
        headers: {
          'Authorization': `Bearer ${process.env.KIE_AI_API_KEY}`
        }
      });

      const data = await response.json();
      if (data.code !== 200) {
        throw new Error(`Failed to get credits: ${data.msg}`);
      }

      return data.data;
    });
  }

  private async logRetry(info: any) {
    // 记录到监控系统
    await fetch('/api/internal/metrics', {
      method: 'POST',
      body: JSON.stringify({
        metric: 'veo_api_retry',
        ...info
      })
    });
  }
}

export const veoAPIClient = new VeoAPIClient();
```

## 🔌 API 端点实现

### 视频生成接口（带完整限流）

```typescript
// src/app/api/generate-video/route.ts

import { NextRequest, NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { globalLimiter } from '@/lib/rate-limiter';
import { userRateLimiter } from '@/lib/user-rate-limiter';
import { veoAPIClient } from '@/lib/veo-api-client';
import { checkCostAvailability } from '@/lib/cost-control';

export async function POST(request: NextRequest) {
  try {
    // 1. 认证
    const session = await getServerSession();
    if (!session?.user) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    const userId = session.user.id;
    const userTier = session.user.tier || 'free';

    // 2. 用户级限流检查
    const rateLimitCheck = await userRateLimiter.checkLimit(userId, userTier);
    if (!rateLimitCheck.allowed) {
      return NextResponse.json(
        {
          error: 'RATE_LIMIT_EXCEEDED',
          message: getRateLimitMessage(rateLimitCheck.reason),
          retryAfter: rateLimitCheck.retryAfter
        },
        {
          status: 429,
          headers: {
            'X-RateLimit-Reason': rateLimitCheck.reason!,
            'Retry-After': rateLimitCheck.retryAfter!.toString()
          }
        }
      );
    }

    // 3. 解析请求
    const body = await request.json();
    const { prompt, model, aspectRatio, generationType, imageUrls } = body;

    // 4. 成本检查
    const costCheck = await checkCostAvailability({
      userId,
      model,
      generationType,
      aspectRatio
    });

    if (!costCheck.allowed) {
      return NextResponse.json(
        {
          error: 'INSUFFICIENT_CREDITS',
          message: costCheck.reason,
          required: costCheck.required,
          available: costCheck.available
        },
        { status: 402 }
      );
    }

    // 5. 全局并发控制
    const result = await globalLimiter.acquire(async () => {
      try {
        // 6. 调用 kie.ai API（自动重试）
        const { taskId } = await veoAPIClient.generateVideo({
          prompt,
          model: model || 'veo3_fast',
          aspectRatio: aspectRatio || '16:9',
          generationType: generationType || 'TEXT_2_VIDEO',
          imageUrls,
          callBackUrl: `${process.env.APP_URL}/api/veo/callback`
        });

        // 7. 扣除 credits
        await deductUserCredits(userId, costCheck.required, taskId);

        // 8. 保存任务记录
        await saveVideoTask({
          taskId,
          userId,
          prompt,
          model,
          estimatedCost: costCheck.estimatedCost,
          status: 'pending'
        });

        return { taskId };

      } catch (error: any) {
        // 释放用户并发槽位
        await userRateLimiter.releaseConcurrent(userId);
        throw error;
      }
    });

    return NextResponse.json({
      success: true,
      taskId: result.taskId
    });

  } catch (error: any) {
    console.error('[GenerateVideo] Error:', error);

    // 根据错误类型返回不同状态码
    if (error.code === 429) {
      return NextResponse.json(
        { error: 'EXTERNAL_RATE_LIMIT', message: 'kie.ai API rate limit exceeded' },
        { status: 503, headers: { 'Retry-After': '60' } }
      );
    }

    if (error.code === 402) {
      return NextResponse.json(
        { error: 'PLATFORM_CREDITS_DEPLETED', message: 'kie.ai credits insufficient' },
        { status: 503 }
      );
    }

    return NextResponse.json(
      { error: 'INTERNAL_ERROR', message: error.message },
      { status: 500 }
    );
  }
}

function getRateLimitMessage(reason?: string): string {
  const messages = {
    'MAX_CONCURRENT_REACHED': '您已达到最大并发生成数，请等待现有任务完成',
    'MINUTE_QUOTA_EXCEEDED': '您已达到每分钟生成限制，请稍后重试',
    'HOURLY_QUOTA_EXCEEDED': '您已达到每小时生成限制，请稍后重试',
    'DAILY_QUOTA_EXCEEDED': '您已达到今日生成限制，请明天再试或升级套餐'
  };
  return messages[reason as keyof typeof messages] || '请求过于频繁，请稍后重试';
}
```

### 用户配额查询接口

```typescript
// src/app/api/quota-status/route.ts

export async function GET(request: NextRequest) {
  const session = await getServerSession();
  if (!session?.user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const userId = session.user.id;
  const userTier = session.user.tier || 'free';

  // 获取配额状态
  const quotaStatus = await userRateLimiter.getUserQuotaStatus(userId, userTier);

  // 获取全局负载
  const globalStats = globalLimiter.getStats();

  return NextResponse.json({
    user: {
      tier: userTier,
      quotas: quotaStatus
    },
    system: {
      load: globalStats.loadPercentage,
      available: globalStats.max - globalStats.current
    }
  });
}
```

## 📊 接口监控 Dashboard

### 限流监控指标

```typescript
// src/app/api/admin/rate-limit-monitoring/route.ts

export async function GET() {
  const stats = {
    // 全局统计
    global: {
      concurrent: globalLimiter.getStats(),
      qps: await getQPS(),
      avgResponseTime: await getAvgResponseTime()
    },

    // 用户统计（Top 10）
    topUsers: await getTopUsersByRequests(10),

    // 限流事件
    rateLimitEvents: {
      lastHour: await getRateLimitEvents('hour'),
      byReason: await getRateLimitEventsByReason('hour'),
      byUser: await getTopRateLimitedUsers('hour', 10)
    },

    // kie.ai API 统计
    kieAPI: {
      successRate: await getKieAPISuccessRate('hour'),
      avgLatency: await getKieAPILatency('hour'),
      retries: await getKieAPIRetries('hour'),
      rateLimitHits: await getKieAPIRateLimits('hour')
    },

    // 健康状态
    health: {
      redisConnected: await checkRedisHealth(),
      queueDepth: globalLimiter.getStats().queued,
      systemLoad: globalLimiter.getCurrentLoad()
    }
  };

  return Response.json(stats);
}
```

## ⚙️ 配置管理

### 动态配置（可热更新）

```typescript
// src/lib/config-manager.ts

class ConfigManager {
  private config: any = {};

  async loadConfig() {
    // 从数据库或配置中心加载
    this.config = await db.query('SELECT * FROM system_config WHERE key = ?', ['rate_limit']);
  }

  getGlobalConcurrency(): number {
    return this.config.global_concurrency || 10;
  }

  getUserRateLimit(tier: string): RateLimitConfig {
    return this.config.user_limits?.[tier] || RATE_LIMITS[tier];
  }

  async updateConfig(key: string, value: any) {
    await db.query('UPDATE system_config SET value = ? WHERE key = ?', [value, key]);
    await this.loadConfig();
  }
}

export const configManager = new ConfigManager();

// 定期刷新配置（每 5 分钟）
setInterval(() => {
  configManager.loadConfig();
}, 5 * 60 * 1000);
```

## 🚨 告警规则

```typescript
// src/jobs/rate-limit-monitor.ts

export async function monitorRateLimits() {
  // 1. 检查全局负载
  const globalLoad = globalLimiter.getCurrentLoad();
  if (globalLoad > 0.9) {
    await sendAlert({
      level: 'WARNING',
      message: `全局并发负载高: ${(globalLoad * 100).toFixed(1)}%`
    });
  }

  // 2. 检查 kie.ai API 健康度
  const kieSuccessRate = await getKieAPISuccessRate('5min');
  if (kieSuccessRate < 0.95) {
    await sendAlert({
      level: 'CRITICAL',
      message: `kie.ai API 成功率低: ${(kieSuccessRate * 100).toFixed(1)}%`
    });
  }

  // 3. 检查 Redis 连接
  if (!await checkRedisHealth()) {
    await sendAlert({
      level: 'EMERGENCY',
      message: 'Redis 连接失败，限流功能不可用！'
    });
  }

  // 4. 检查大量限流事件
  const rateLimitCount = await getRateLimitEvents('5min');
  if (rateLimitCount > 100) {
    await sendAlert({
      level: 'WARNING',
      message: `近 5 分钟触发 ${rateLimitCount} 次限流`
    });
  }
}

// 每分钟执行一次
setInterval(monitorRateLimits, 60 * 1000);
```

## 📋 接口管控检查清单

### 部署前

- [ ] 配置 Redis 连接
- [ ] 设置用户分级限流配置
- [ ] 配置全局并发数
- [ ] 测试重试机制
- [ ] 测试限流响应
- [ ] 配置监控告警

### 运行时监控

- [ ] 全局并发负载
- [ ] 用户限流触发频率
- [ ] kie.ai API 成功率
- [ ] API 响应延迟
- [ ] Redis 健康状态
- [ ] 队列深度

### 优化建议

- 根据实际负载调整并发数
- 根据用户行为调整配额
- 监控 kie.ai 限流规律
- 优化重试策略
- 考虑实现请求队列持久化

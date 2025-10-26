# kie.ai 价格映射表

## 💰 kie.ai 官方价格

### 充值套餐

| 套餐 | kie.ai Credits | 价格 (USD) | 单价 |
|------|---------------|-----------|------|
| 基础 | 1,000 | $5.00 | $0.005/credit |
| - | 2,000 | $10.00 | $0.005/credit |
| - | 5,000 | $25.00 | $0.005/credit |
| - | 10,000 | $50.00 | $0.005/credit |

**单位成本**: $0.005 / credit

---

## 🎬 Veo 3.1 视频生成价格

### kie.ai Credits 消耗

| 模型 | kie.ai Credits | USD 成本 | 说明 |
|------|---------------|---------|------|
| **Veo 3.1 Fast** | 20 credits | $0.10 | 快速模式，2-3分钟 |
| **Veo 3.1 Quality** | 150 credits | $0.75 | 高质量模式，3-5分钟 |

**成本差异**: Quality 模式是 Fast 模式的 **7.5 倍**

### 成本对比

```
100 个视频生成成本：

Fast 模式:
100 × $0.10 = $10.00
需要 2,000 kie.ai credits

Quality 模式:
100 × $0.75 = $75.00
需要 15,000 kie.ai credits
```

---

## 📊 其他 API 价格参考

虽然本项目主要使用 Veo，但 kie.ai 还提供其他 AI 服务：

| API | kie.ai Credits | USD 成本 | 说明 |
|-----|---------------|---------|------|
| 4O Image | 3 | $0.015 | 图片生成 |
| Nano Banana | 2 | $0.010 | 视频生成 |
| Flux Kontext Pro | 4 | $0.020 | 图片生成 |
| Flux Kontext Max | 8 | $0.040 | 图片生成 |
| Runway Aleph | 90 | $0.450 | 视频生成 |
| Sora 2 (无水印) | 6 | $0.030 | 视频生成 |

---

## 🔄 Credits 映射策略

### 方案 1: 固定比例映射

将 kie.ai credits 1:1 映射到网站 credits：

```typescript
// 1 网站 credit = 1 kie.ai credit

const COST_CONFIG = {
  veo3_fast: {
    siteCredits: 20,        // 用户消耗 20 credits
    kieCredits: 20,         // kie.ai 消耗 20 credits
    usdCost: 0.10
  },
  veo3: {
    siteCredits: 150,       // 用户消耗 150 credits
    kieCredits: 150,        // kie.ai 消耗 150 credits
    usdCost: 0.75
  }
};
```

**优点**: 简单直观，用户容易理解
**缺点**: 无利润空间

### 方案 2: 加价映射（推荐）

添加合理利润率：

```typescript
// 1 网站 credit ≠ 1 kie.ai credit

const MARKUP_RATE = 1.5;  // 50% 利润率

const COST_CONFIG = {
  veo3_fast: {
    siteCredits: Math.ceil(20 * MARKUP_RATE),    // 30 credits
    kieCredits: 20,
    usdCost: 0.10,
    revenue: 0.05           // $0.05 利润
  },
  veo3: {
    siteCredits: Math.ceil(150 * MARKUP_RATE),   // 225 credits
    kieCredits: 150,
    usdCost: 0.75,
    revenue: 0.375          // $0.375 利润
  }
};
```

**优点**: 有利润空间，覆盖运营成本
**缺点**: 需要设计合理的充值套餐

### 方案 3: 独立定价（最灵活）

完全独立的定价体系：

```typescript
const COST_CONFIG = {
  veo3_fast: {
    siteCredits: 1,         // 用户消耗 1 credit
    kieCredits: 20,         // kie.ai 消耗 20 credits
    usdCost: 0.10
  },
  veo3: {
    siteCredits: 5,         // 用户消耗 5 credits
    kieCredits: 150,        // kie.ai 消耗 150 credits
    usdCost: 0.75
  }
};

// 用户充值套餐
const USER_PACKAGES = {
  basic: {
    siteCredits: 10,
    price: 2.00,            // $2 = 10 credits = 10 个 Fast 视频
    kieCreditsRequired: 200
  },
  pro: {
    siteCredits: 100,
    price: 15.00,           // $15 = 100 credits = 100 个 Fast 视频
    kieCreditsRequired: 2000
  },
  premium: {
    siteCredits: 1000,
    price: 120.00,          // $120 = 1000 credits
    kieCreditsRequired: 20000
  }
};
```

**优点**:
- 最灵活，可以独立调整价格
- 用户看到的数字更友好（1 credit vs 20 credits）
- 方便推出会员套餐

**缺点**: 需要更复杂的充值逻辑

---

## 💡 推荐方案

### 方案 3 变体：简化版

```typescript
// 配置文件：src/config/pricing.ts

export const VIDEO_PRICING = {
  fast: {
    displayName: 'Fast 模式',
    userCredits: 1,           // 用户看到：消耗 1 credit
    kieCredits: 20,           // 实际消耗 20 kie.ai credits
    usdCost: 0.10,
    estimatedTime: '2-3分钟'
  },
  quality: {
    displayName: 'Quality 模式',
    userCredits: 5,           // 用户看到：消耗 5 credits
    kieCredits: 150,          // 实际消耗 150 kie.ai credits
    usdCost: 0.75,
    estimatedTime: '3-5分钟'
  }
};

// 用户充值套餐
export const CREDIT_PACKAGES = [
  {
    id: 'starter',
    name: 'Starter',
    credits: 10,
    price: 2.99,
    popular: false,
    description: '约 10 个 Fast 视频'
  },
  {
    id: 'basic',
    name: 'Basic',
    credits: 50,
    price: 9.99,
    popular: false,
    description: '约 50 个 Fast 视频'
  },
  {
    id: 'pro',
    name: 'Pro',
    credits: 150,
    price: 24.99,
    popular: true,
    bonus: 10,              // 赠送 10 credits
    description: '约 160 个 Fast 视频'
  },
  {
    id: 'enterprise',
    name: 'Enterprise',
    credits: 500,
    price: 74.99,
    popular: false,
    bonus: 50,
    description: '约 550 个 Fast 视频'
  }
];

// 计算需要的 kie.ai credits
export function calculateRequiredKieCredits(packageId: string): number {
  const pkg = CREDIT_PACKAGES.find(p => p.id === packageId);
  if (!pkg) throw new Error('Invalid package');

  const totalCredits = pkg.credits + (pkg.bonus || 0);

  // 假设用户平均使用 Fast 模式
  // 1 用户 credit = 20 kie.ai credits (Fast)
  return totalCredits * VIDEO_PRICING.fast.kieCredits;
}
```

### 价格展示示例

前端展示：

```tsx
<div className="pricing-card">
  <h3>Fast 模式</h3>
  <div className="cost">
    <span className="credits">1</span> credit
  </div>
  <ul>
    <li>生成时间：2-3分钟</li>
    <li>质量：标准</li>
    <li>适合预览和测试</li>
  </ul>
</div>

<div className="pricing-card popular">
  <h3>Quality 模式</h3>
  <div className="cost">
    <span className="credits">5</span> credits
  </div>
  <ul>
    <li>生成时间：3-5分钟</li>
    <li>质量：高清 1080P</li>
    <li>适合正式发布</li>
  </ul>
</div>
```

---

## 📈 成本计算工具

### 成本预估函数

```typescript
// src/lib/cost-calculator.ts

import { VIDEO_PRICING } from '@/config/pricing';

export function calculateCost(params: {
  model: 'fast' | 'quality';
  count: number;
}): {
  userCredits: number;
  kieCredits: number;
  usdCost: number;
} {
  const pricing = VIDEO_PRICING[params.model];

  return {
    userCredits: pricing.userCredits * params.count,
    kieCredits: pricing.kieCredits * params.count,
    usdCost: pricing.usdCost * params.count
  };
}

// 使用示例
const cost = calculateCost({ model: 'fast', count: 100 });
console.log(`
  用户消耗: ${cost.userCredits} credits
  kie.ai 消耗: ${cost.kieCredits} credits
  实际成本: $${cost.usdCost}
`);
// 输出：
// 用户消耗: 100 credits
// kie.ai 消耗: 2000 credits
// 实际成本: $10
```

### 利润计算

```typescript
export function calculateRevenue(params: {
  model: 'fast' | 'quality';
  count: number;
  packagePrice: number;
}): {
  revenue: number;
  cost: number;
  profit: number;
  margin: number;
} {
  const cost = calculateCost(params);

  const revenue = params.packagePrice;
  const kieCost = cost.usdCost;
  const profit = revenue - kieCost;
  const margin = (profit / revenue) * 100;

  return { revenue, cost: kieCost, profit, margin };
}

// 示例：Pro 套餐
const rev = calculateRevenue({
  model: 'fast',
  count: 160,  // 150 + 10 bonus
  packagePrice: 24.99
});

console.log(`
  收入: $${rev.revenue}
  成本: $${rev.cost}
  利润: $${rev.profit}
  利润率: ${rev.margin.toFixed(2)}%
`);
// 输出：
// 收入: $24.99
// 成本: $16.00  (160 × $0.10)
// 利润: $8.99
// 利润率: 35.97%
```

---

## 🎯 定价策略建议

### 1. 分级定价

| 用户等级 | 月费 | 赠送 Credits | Fast 视频数 | Quality 视频数 |
|---------|------|-------------|-----------|--------------|
| Free | $0 | 3 | ~3 | 0 |
| Basic | $9.99 | 50 | ~50 | ~10 |
| Pro | $29.99 | 200 | ~200 | ~40 |
| Enterprise | $99.99 | 1000 | ~1000 | ~200 |

### 2. 按需付费

使用方案 3 的充值包，用户根据需要购买。

### 3. 混合模式（推荐）

- **免费用户**: 注册赠送 3 credits（体验）
- **会员订阅**: 月费 + 固定 credits
- **额外购买**: 可随时充值

---

## 🔍 成本监控指标

### 每日成本报告

```typescript
interface DailyCostReport {
  date: string;

  // 用户侧
  userCreditsSpent: number;
  revenue: number;

  // kie.ai 侧
  kieCreditsSpent: number;
  kieCost: number;

  // 利润
  grossProfit: number;
  profitMargin: number;

  // 任务统计
  totalTasks: number;
  fastTasks: number;
  qualityTasks: number;
  failedTasks: number;

  // 退款
  refundedCredits: number;
  refundedAmount: number;
}
```

### 成本预警

```typescript
const ALERT_THRESHOLDS = {
  // 利润率过低
  minProfitMargin: 20,  // 低于 20% 预警

  // 失败率过高（浪费成本）
  maxFailureRate: 5,    // 超过 5% 预警

  // kie.ai 余额
  minKieBalance: 5000,  // 低于 5000 credits 预警

  // 日成本上限
  maxDailyCost: 100,    // 超过 $100/天 预警
};
```

---

## 📋 实施清单

- [ ] 决定 credits 映射方案（推荐方案 3）
- [ ] 设计用户充值套餐
- [ ] 配置 `src/config/pricing.ts`
- [ ] 实现成本计算函数
- [ ] 创建利润监控 Dashboard
- [ ] 设置成本预警
- [ ] 测试完整充值-消耗-退款流程
- [ ] 文档化给前端团队

---

## 💡 附加优化建议

### 1. 首次充值优惠

```typescript
const FIRST_TIME_BONUS = {
  basic: { bonus: 5, description: '首充送 5 credits' },
  pro: { bonus: 20, description: '首充送 20 credits' },
  enterprise: { bonus: 100, description: '首充送 100 credits' }
};
```

### 2. 会员特权

```typescript
const MEMBER_BENEFITS = {
  free: {
    priority: 'low',
    concurrent: 1,
    queuePriority: 0
  },
  pro: {
    priority: 'high',
    concurrent: 3,
    queuePriority: 10,
    discount: 0.1  // 10% off
  }
};
```

### 3. 推荐奖励

```typescript
const REFERRAL_REWARDS = {
  referrer: 10,    // 推荐人获得 10 credits
  referee: 5       // 被推荐人获得 5 credits
};
```

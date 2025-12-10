# Image Pricing System Skill

## Overview

This skill documents the complete pricing system for the Nano Banana image editing platform (GemPix2). The system uses a credit-based model with transparent pricing tiers supporting monthly and yearly billing.

## Pricing Tiers

### Monthly Billing

| Tier | Price | Credits | Images | Videos | Features |
|------|-------|---------|--------|--------|----------|
| Free | $0 | 6 | 2 | - | Standard Quality, Perfect for exploring |
| Professional | $12.90 | 500 | 166 | 25 | Advanced Quality, Watermark-free, Commercial license |
| Enterprise | $59.90 | 5,000 | 1,666 | 250 | Priority support, Commercial license, Dedicated manager |

### Annual Billing (with discounts)

| Tier | Price | Credits | Images | Videos | Savings | Features |
|------|-------|---------|--------|--------|---------|----------|
| Professional | $118.80/year ($9.90/mo) | 6,000 | 2,000 | 300 | Save $36/year (33% off) | All Professional features |
| Enterprise | $478.80/year ($39.90/mo) | 60,000 | 20,000 | 3,000 | Save $240/year (33% off) | All Enterprise features |

## Credit System

### Credit Consumption Rates

- **Nano Banana Image Editing**: 3 credits per edit (~$0.02)
- **Veo3 Video Generation**: 20 credits per video (~$0.13)

### Credit Conversion Examples

**Image Generation (3 credits = 1 image)**
- Free: 6 credits = 2 images
- Professional: 500 credits = 166 images
- Enterprise: 5,000 credits = 1,666 images

**Video Generation (20 credits = 1 video)**
- Professional: 500 credits = 25 videos
- Enterprise: 5,000 credits = 250 videos

### Credit Allocation Strategy

Users receive credits through:
1. **New Account**: 6 free credits on signup (covers ~2 images)
2. **Paid Plans**: Monthly or annual subscription credits
3. **Bonus Campaigns**: Limited-time promotions (e.g., BANANA25 - 25% off)

## Pricing Architecture

### Design Principles

1. **Image-First Focus**: Image editing is the primary product (3 credits/edit)
2. **Video as Bonus**: Veo3 video generation is secondary (20 credits/edit)
3. **Fair Pricing**: Credit cost reflects ~$0.005 per credit
4. **Flexibility**: Users can spend credits on any feature without artificial limits

### Profit Margin Analysis

#### Image Scenario
- Cost per image: ~$0.01 (inference + storage)
- Revenue per image at tier prices:
  - Free: $0 (customer acquisition)
  - Professional: $0.078/image ($12.90 / 166 images)
  - Enterprise: $0.036/image ($59.90 / 1,666 images)
- **Margin**: 7.8x - 87.7% profit (excluding overhead)

#### Video Scenario (Veo3)
- Cost per video: ~$0.50 (longer inference, larger storage)
- Revenue per video at tier prices:
  - Professional: $0.516/video ($12.90 / 25 videos)
  - Enterprise: $0.240/video ($59.90 / 250 videos)
- **Margin**: Requires careful monitoring of video adoption

### Key Metrics for Cost Monitoring

Monitor these ratios to ensure profitability:
1. **Image Cost Ratio**: Actual image generation cost vs. $0.01 baseline
2. **Video Cost Ratio**: Actual Veo3 cost vs. $0.50 baseline
3. **Monthly Active Images**: Track usage patterns per tier
4. **Annual Savings Impact**: Monitor discount redemption rate

## Campaign Strategy

### BANANA25 Limited-Time Offer
- **Discount**: 25% off all monthly tiers
- **Code**: BANANA25
- **Duration**: Limited time (update in pricing footnotes)
- **Target Audience**: New users and tier upgrades

**Effective Monthly Prices with BANANA25**:
- Professional: $12.90 → $9.68
- Enterprise: $59.90 → $44.93

## Localization

### Supported Languages

All pricing content is localized to:
- English (en) - `/src/i18n/pages/pricing/en.json`
- Chinese Simplified (zh) - `/src/i18n/pages/pricing/zh.json`
- Korean (ko) - `/src/i18n/pages/pricing/ko.json`
- Russian (ru) - `/src/i18n/pages/pricing/ru.json`

### Landing Page Pricing

- **Landing Pricing** (`/src/i18n/pages/gempix2-landing/*/pricing.json`)
  - Simplified 3-tier presentation (Free/Professional/Enterprise)
  - Focus on key metrics (credits, image count, price)
  - CTA buttons link to signup or pricing page

- **Full Pricing** (`/src/i18n/pages/pricing/*/json`)
  - Detailed 5-item structure (3 monthly + 2 annual)
  - Complete feature lists
  - Savings callouts for annual plans

## Implementation Notes

### Structure Validation

Each pricing JSON file must contain:
1. **Main pricing tiers**: Free/Professional/Enterprise in same order
2. **Items array**: Exactly 5 elements (3 monthly + 2 yearly)
3. **Consistent schema**: All items include title, description, features, button, product_id
4. **Localized content**: All text translated, numbers preserved

### Important: No Freedom AI References

All pricing content has been migrated from legacy "Freedom AI" brand. Ensure:
- No "Freedom AI" mentions in any pricing files
- Product names use "Nano" prefix (e.g., "Nano Professional Monthly")
- All localization files follow the same structure

### Migration Checklist

- [x] English pricing (en.json) - converted to Free/Professional/Enterprise model
- [x] Korean pricing (ko.json) - translated and validated
- [x] Russian pricing (ru.json) - translated and validated
- [x] Landing English (gempix2-landing/en/pricing.json) - simplified 3-tier structure
- [x] Landing Chinese (gempix2-landing/zh/pricing.json) - translated and simplified

## Risk Management

### Cost Escalation Risks

1. **Image Generation Spike**: If actual cost exceeds $0.01/image
   - Action: Monitor monthly costs vs. projected $0.01 baseline
   - Alert threshold: >$0.015/image (50% over budget)

2. **Video Adoption Surge**: Veo3 video generation gaining unexpected popularity
   - Action: Veo3 is priced at 20 credits vs. 3 for images
   - Alert threshold: >20% of plan consumption as videos

3. **Discount Abuse**: BANANA25 or other campaigns creating margin pressure
   - Action: Track conversion rate and AOV (average order value)
   - Decision: Rotate campaigns monthly or adjust discount percentage

### Monitoring Strategy

- Track actual per-feature cost monthly
- Compare revenue per image/video vs. projections
- Monitor tier adoption distribution
- Alert when image cost exceeds $0.015 or video cost exceeds $0.75

## Related Files

See `/references/cost-analysis.md` for detailed cost breakdown and profitability scenarios.

## Maintenance Schedule

- **Monthly**: Review actual costs vs. projections
- **Quarterly**: Analyze tier adoption and revenue trends
- **Semi-annually**: Evaluate campaign effectiveness and discount strategy
- **Annually**: Benchmark pricing against competitors and market conditions

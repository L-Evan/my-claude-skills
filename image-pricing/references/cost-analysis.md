# Cost Analysis Reference

## Infrastructure Costs

### Image Generation (Nano Banana)

**Per-Image Cost Breakdown:**
- Model inference: ~$0.008
  - Based on API pricing for image generation models
  - Optimized for batch processing
- Storage (CDN + backup): ~$0.001
  - S3-compatible storage: $0.023/GB (assumed 5KB per image)
  - CDN delivery: minimal for cached images
- Compute overhead: ~$0.001
  - Database operations, webhooks, logging

**Total per image: ~$0.01**

### Video Generation (Veo3)

**Per-Video Cost Breakdown:**
- Model inference: ~$0.40
  - Veo3 is more expensive than image generation
  - Typical 5-10 second video at 1024p
- Storage (CDN + backup): ~$0.05
  - Video files are 50-100MB depending on quality
  - Multiple quality tiers stored
- Compute overhead: ~$0.05
  - Longer processing pipeline
  - More complex storage management

**Total per video: ~$0.50**

## Profitability Analysis

### Scenario 1: Free Tier (Customer Acquisition)
- Revenue: $0
- Cost: 6 credits * $0.003 = $0.018
- Margin: -$0.018
- **Purpose**: Freemium acquisition, 2 free image trials

### Scenario 2: Professional Monthly ($12.90/month)
- Revenue: $12.90
- Credits sold: 500
- Usage assumptions:
  - 80% images (400 credits = 133 images)
  - 20% videos (100 credits = 5 videos)
- Cost: (133 * $0.01) + (5 * $0.50) = $4.83
- **Gross Margin**: $12.90 - $4.83 = $8.07 (62.6%)
- **Net Margin (30% overhead)**: $8.07 * 0.7 = $5.65 (43.8%)

### Scenario 3: Professional Annual ($118.80/year = $9.90/month)
- Revenue: $118.80/year
- Credits sold: 6,000 annually (500/month average)
- Cost: Same $4.83/month = $57.96/year
- **Gross Margin**: $118.80 - $57.96 = $60.84 (51.2%)
- **Net Margin (30% overhead)**: $60.84 * 0.7 = $42.59 (35.8%)

### Scenario 4: Enterprise Monthly ($59.90/month)
- Revenue: $59.90
- Credits sold: 5,000
- Usage assumptions:
  - 85% images (4,250 credits = 1,416 images)
  - 15% videos (750 credits = 37.5 videos)
- Cost: (1,416 * $0.01) + (37.5 * $0.50) = $32.91
- **Gross Margin**: $59.90 - $32.91 = $26.99 (45.1%)
- **Net Margin (30% overhead)**: $26.99 * 0.7 = $18.89 (31.5%)

### Scenario 5: Enterprise Annual ($478.80/year = $39.90/month)
- Revenue: $478.80/year
- Credits sold: 60,000 annually (5,000/month average)
- Cost: Same $32.91/month = $394.92/year
- **Gross Margin**: $478.80 - $394.92 = $83.88 (17.5%)
- **Net Margin (30% overhead)**: $83.88 * 0.7 = $58.72 (12.3%)

## Key Financial Metrics

### Revenue per Customer Archetype

Assuming typical usage patterns:

| Tier | Monthly Revenue | Annual Revenue | Gross Margin | % of Margin |
|------|-----------------|-----------------|-----------------|-------------|
| Free | $0 | $0 | -$0.02 | 0% |
| Professional (Mo) | $12.90 | $154.80 | $8.07/mo | 62.6% |
| Professional (Yr) | $9.90 | $118.80 | $42.59/yr | 35.8% |
| Enterprise (Mo) | $59.90 | $718.80 | $26.99/mo | 45.1% |
| Enterprise (Yr) | $39.90 | $478.80 | $58.72/yr | 12.3% |

### Unit Economics

**Cost per Credit**: $0.003 average
- Based on: (image cost * image %) + (video cost * video %)
- Professional: $0.0097/credit (496 image credits + 4 video credits)
- Enterprise: $0.0066/credit (4,250 image credits + 37.5 video credits)

**Revenue per Credit**:
- Professional Monthly: $0.0258/credit ($12.90 / 500)
- Professional Annual: $0.0198/credit ($118.80 / 6,000)
- Enterprise Monthly: $0.01198/credit ($59.90 / 5,000)
- Enterprise Annual: $0.00798/credit ($478.80 / 60,000)

## Break-Even Analysis

### Customer Acquisition Cost (CAC) Payback

**Assumptions:**
- Annual premium tier customer costs $50 to acquire
- Professional tier generates $8.07/month margin

**Professional Monthly**: Pays back CAC in ~6 months (50 / 8.07)
**Professional Annual**: Single annual purchase, customer must exceed $59.90 revenue to break even

### Churn Impact

Monthly subscription churn directly impacts profitability:
- 5% monthly churn: Professional customer lifetime value = $96.84 (12 * $8.07)
- 10% monthly churn: Professional customer lifetime value = $48.42
- CAC of $50 becomes profitable at <4% monthly churn

## Sensitivity Analysis

### What if actual image cost = $0.015 (50% higher)?

**Professional Monthly Impact:**
- Cost: (133 * $0.015) + (5 * $0.50) = $4.495
- Margin change: -$0.335 per customer
- **New margin**: 6.5% (down from 62.6%)

**Recommendation**: Increase Professional tier price to $15.90 or reduce feature/quality

### What if video adoption = 30% of consumption?

**Professional Monthly Impact:**
- Cost: (350 * $0.01) + (30 * $0.50) = $18.50
- Margin change: -$9.67 per customer
- **New margin**: Negative! (Revenue: $12.90, Cost: $18.50)

**Recommendation**: Adjust video credits to 15 credits/video or increase Professional to $25/month

### What if BANANA25 (25% discount) drives 40% of conversions?

**Blended Professional Monthly Revenue:**
- 60% at $12.90 = $7.74
- 40% at $9.68 = $3.87
- **Blended**: $11.61/month (10% lower)

**Impact on break-even**: CAC payback extends from 6 months to 7 months

## Pricing Recommendations

### Conservative Positioning (current pricing)
- Focuses on image editing as primary product
- Veo3 videos are supplementary benefit
- Assumes 20% max video consumption
- Sustainable margins if cost assumptions hold

### Aggressive Positioning (potential future)
- Professional: $19.90/month (higher confidence in margins)
- Enterprise: $79.90/month
- Benefits: Increased margin, reduce churn sensitivity
- Risk: Lower conversion rate from free to paid

### Defensive Positioning (cost escalation hedge)
- Professional: $15.90/month (protect against 50% cost increase)
- Enterprise: $69.90/month
- Benefits: Buffer against cost inflation
- Risk: Competitive disadvantage vs. alternatives

## Monitoring Checklist

Weekly:
- [ ] Actual image generation cost vs. $0.01 baseline
- [ ] Video adoption rate in each tier

Monthly:
- [ ] Gross margin per tier vs. projections
- [ ] Customer acquisition cost by source
- [ ] Churn rate by tier

Quarterly:
- [ ] Revenue per customer vs. CAC payback period
- [ ] Sensitivity to video cost changes
- [ ] Campaign ROI (e.g., BANANA25 effectiveness)

## References

- Nano Banana pricing tiers: `/src/i18n/pages/pricing/en.json`
- Landing page simplified pricing: `/src/i18n/pages/gempix2-landing/en/pricing.json`
- Related skill: `/image-pricing/SKILL.md`

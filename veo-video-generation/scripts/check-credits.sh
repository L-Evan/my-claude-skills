#!/bin/bash

# Veo Video Generation - Credits Check Script
# 检查 kie.ai credits 余额并发送告警

set -e

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 配置
KIE_AI_API_KEY="${KIE_AI_API_KEY}"
KIE_AI_API_URL="https://api.kie.ai"
ALERT_EMAIL="${ALERT_EMAIL:-admin@example.com}"

# 阈值配置
CRITICAL_THRESHOLD=500
WARNING_THRESHOLD=1000
LOW_THRESHOLD=3000
SAFE_THRESHOLD=5000

# 检查环境变量
if [ -z "$KIE_AI_API_KEY" ]; then
  echo -e "${RED}错误: KIE_AI_API_KEY 环境变量未设置${NC}"
  echo "请设置: export KIE_AI_API_KEY=your_api_key"
  exit 1
fi

# 打印配置
echo "==================================="
echo "Veo Credits 检查工具"
echo "==================================="
echo ""
echo "API URL: $KIE_AI_API_URL"
echo "阈值设置:"
echo "  - 安全: >= $SAFE_THRESHOLD"
echo "  - 低余额: < $LOW_THRESHOLD"
echo "  - 警告: < $WARNING_THRESHOLD"
echo "  - 严重: < $CRITICAL_THRESHOLD"
echo ""

# 查询余额
echo "正在查询 kie.ai credits 余额..."
RESPONSE=$(curl -s -X GET "$KIE_AI_API_URL/api/v1/chat/credit" \
  -H "Authorization: Bearer $KIE_AI_API_KEY" \
  -H "Content-Type: application/json")

# 解析响应
CODE=$(echo "$RESPONSE" | jq -r '.code // "error"')
MSG=$(echo "$RESPONSE" | jq -r '.msg // "unknown"')
CREDITS=$(echo "$RESPONSE" | jq -r '.data // 0')

# 检查是否成功
if [ "$CODE" != "200" ]; then
  echo -e "${RED}❌ 查询失败${NC}"
  echo "错误码: $CODE"
  echo "错误信息: $MSG"
  echo "响应: $RESPONSE"
  exit 1
fi

# 显示余额
echo -e "${GREEN}✅ 查询成功${NC}"
echo ""
echo "==================================="
echo -e "当前余额: ${GREEN}$CREDITS${NC} credits"
echo "==================================="
echo ""

# 成本计算
FAST_VIDEOS=$((CREDITS / 20))
QUALITY_VIDEOS=$((CREDITS / 150))
USD_VALUE=$(echo "scale=2; $CREDITS * 0.005" | bc)

echo "可生成视频数:"
echo "  - Veo 3.1 Fast: ~$FAST_VIDEOS 个"
echo "  - Veo 3.1 Quality: ~$QUALITY_VIDEOS 个"
echo "  - 等值金额: ~\$$USD_VALUE USD"
echo ""

# 状态判断
STATUS=""
if [ "$CREDITS" -ge "$SAFE_THRESHOLD" ]; then
  STATUS="${GREEN}✅ 安全${NC}"
  LEVEL="INFO"
elif [ "$CREDITS" -ge "$LOW_THRESHOLD" ]; then
  STATUS="${GREEN}✓ 正常${NC}"
  LEVEL="INFO"
elif [ "$CREDITS" -ge "$WARNING_THRESHOLD" ]; then
  STATUS="${YELLOW}⚠️  低余额${NC}"
  LEVEL="WARNING"
elif [ "$CREDITS" -ge "$CRITICAL_THRESHOLD" ]; then
  STATUS="${RED}🔴 警告${NC}"
  LEVEL="CRITICAL"
else
  STATUS="${RED}🚨 严重不足${NC}"
  LEVEL="EMERGENCY"
fi

echo -e "状态: $STATUS"
echo ""

# 建议
if [ "$CREDITS" -lt "$WARNING_THRESHOLD" ]; then
  echo "==================================="
  echo "⚠️  建议操作:"
  echo "==================================="

  if [ "$CREDITS" -lt "$CRITICAL_THRESHOLD" ]; then
    echo "1. 🚨 立即充值 kie.ai credits！"
    echo "2. 🔴 暂停新的视频生成任务"
    echo "3. 📧 通知管理员和开发团队"
    echo ""
    echo "充值链接: https://kie.ai/api-key"
    echo ""

    # 发送紧急邮件（如果配置了）
    if command -v mail &> /dev/null; then
      echo "发送紧急告警邮件到 $ALERT_EMAIL..."
      echo "kie.ai credits 严重不足！当前余额: $CREDITS credits，建议立即充值。" | \
        mail -s "🚨 [CRITICAL] kie.ai Credits 不足" "$ALERT_EMAIL"
    fi
  elif [ "$CREDITS" -lt "$WARNING_THRESHOLD" ]; then
    echo "1. ⚠️  建议在 24 小时内充值"
    echo "2. 📊 监控消耗速度"
    echo "3. 💡 考虑限制高成本的 Quality 模式"
    echo ""
  elif [ "$CREDITS" -lt "$LOW_THRESHOLD" ]; then
    echo "1. 💡 建议计划充值时间"
    echo "2. 📊 查看每日消耗趋势"
    echo ""
  fi
fi

# 输出 JSON 格式（用于脚本集成）
if [ "$1" == "--json" ]; then
  echo ""
  echo "==================================="
  echo "JSON 输出:"
  echo "==================================="
  cat <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "credits": $CREDITS,
  "usdValue": $USD_VALUE,
  "status": "$LEVEL",
  "canGenerate": {
    "fast": $FAST_VIDEOS,
    "quality": $QUALITY_VIDEOS
  },
  "thresholds": {
    "critical": $CRITICAL_THRESHOLD,
    "warning": $WARNING_THRESHOLD,
    "low": $LOW_THRESHOLD,
    "safe": $SAFE_THRESHOLD
  },
  "alerts": $([ "$CREDITS" -lt "$WARNING_THRESHOLD" ] && echo "true" || echo "false")
}
EOF
fi

# 退出码
if [ "$CREDITS" -lt "$CRITICAL_THRESHOLD" ]; then
  exit 2  # 严重
elif [ "$CREDITS" -lt "$WARNING_THRESHOLD" ]; then
  exit 1  # 警告
else
  exit 0  # 正常
fi

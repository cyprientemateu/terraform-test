#!/bin/bash
# 1-Minute Retention Test Script

echo "⚡ ECR CLEANUP - 1 MINUTE RETENTION TEST"
echo "======================================="
echo "⏰ Current time: $(date)"
echo ""

# Test Lambda function
echo "🚀 Running 1-minute retention test..."
aws lambda invoke \
  --function-name ecr-cleanup-ecr-cleanup \
  --payload '{}' \
  test_result.json

echo ""
echo "📋 Test Result:"
cat test_result.json | jq '.' 2>/dev/null || cat test_result.json
echo ""

echo "📝 Recent logs:"
aws logs filter-log-events \
  --log-group-name /aws/lambda/ecr-cleanup-ecr-cleanup \
  --start-time $(date -d '2 minutes ago' +%s)000 \
  --query 'events[*].message' \
  --output text | tail -15

echo ""
echo "✅ Test complete!"
echo "🔄 Automatic runs every 2 minutes"

rm -f test_result.json
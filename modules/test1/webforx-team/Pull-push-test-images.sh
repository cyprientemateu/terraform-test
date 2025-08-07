#!/bin/bash
# Push test images to ECR for 1-minute retention testing

set -e

echo "🚀 Pushing test images to ECR repository: test-ecr-cleanup"
echo "============================================================"

# Get AWS account and region
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)
REGISTRY="$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
REPO_NAME="test-ecr-cleanup"

echo "📋 Account: $ACCOUNT"
echo "📋 Region: $REGION"
echo "📋 Registry: $REGISTRY"
echo ""

# Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REGISTRY"

echo "🐳 Pulling Alpine image (small test image)..."
docker pull alpine:latest

echo ""
echo "🏗️ Tagging and pushing test images..."

# Tag and push 4 different images
echo "   → Pushing old-image..."
docker tag alpine:latest "$REGISTRY/$REPO_NAME:old-image"
docker push "$REGISTRY/$REPO_NAME:old-image"

echo "   → Pushing latest..."
docker tag alpine:latest "$REGISTRY/$REPO_NAME:latest"
docker push "$REGISTRY/$REPO_NAME:latest"

echo "   → Pushing base_image..."
docker tag alpine:latest "$REGISTRY/$REPO_NAME:base_image"
docker push "$REGISTRY/$REPO_NAME:base_image"

echo "   → Pushing v1.0..."
docker tag alpine:latest "$REGISTRY/$REPO_NAME:v1.0"
docker push "$REGISTRY/$REPO_NAME:v1.0"

echo ""
echo "✅ SUCCESS! Test images pushed to ECR"
echo ""
echo "📦 Repository: $REPO_NAME"
echo "🏷️ Images created:"
echo "   • old-image (will be deleted after 1 min)"
echo "   • latest (will be deleted after 1 min)"
echo "   • base_image (will be preserved)"
echo "   • v1.0 (will be preserved)"
echo ""
echo "🔍 Verify with: aws ecr describe-images --repository-name $REPO_NAME"
echo "⏰ Wait 1+ minutes, then test with: ./test_1min.sh"
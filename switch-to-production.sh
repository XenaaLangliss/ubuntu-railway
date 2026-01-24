#!/bin/bash

# Script to switch from VM deployment to Production LiveKit deployment

set -e

echo "╔══════════════════════════════════════════════════╗"
echo "║  Switching to Production LiveKit Deployment     ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Check if we're in the right directory
if [ ! -f "railway.production.json" ]; then
    echo "❌ Error: railway.production.json not found"
    echo "   Make sure you're in the project root directory"
    exit 1
fi

echo "📋 Step 1: Backing up current railway.json..."
if [ -f "railway.json" ]; then
    cp railway.json railway.json.backup
    echo "   ✅ Backup created: railway.json.backup"
else
    echo "   ℹ️  No existing railway.json found"
fi

echo ""
echo "📋 Step 2: Switching to production configuration..."
cp railway.production.json railway.json
echo "   ✅ railway.json updated to use Dockerfile.livekit"

echo ""
echo "📋 Step 3: Checking LiveKit configuration..."
if [ ! -f "livekit-production.yaml" ]; then
    echo "   ⚠️  Warning: livekit-production.yaml not found"
    echo "   Creating from livekit-config.yaml..."
    cp livekit-config.yaml livekit-production.yaml
fi
echo "   ✅ Configuration ready"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║              ⚠️  IMPORTANT NEXT STEPS            ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "1. Generate new API keys:"
echo "   docker run --rm livekit/livekit-server generate-keys"
echo ""
echo "2. Update livekit-production.yaml with your API keys"
echo ""
echo "3. Commit and push changes:"
echo "   git add railway.json livekit-production.yaml"
echo "   git commit -m 'Switch to production LiveKit deployment'"
echo "   git push"
echo ""
echo "4. Railway will automatically redeploy with the new configuration"
echo ""
echo "5. Expose port 7880 in Railway Dashboard:"
echo "   Settings → Networking → Add Port → 7880"
echo ""
echo "📖 See RAILWAY_DEPLOYMENT.md for complete instructions"
echo ""

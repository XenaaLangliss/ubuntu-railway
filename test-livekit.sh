#!/bin/bash

# LiveKit Connection Test Script
# Tests connectivity to your LiveKit server

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "╔══════════════════════════════════════════════════╗"
echo "║          LiveKit Connection Test                 ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Get server URL
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <server-url> [api-key] [api-secret]${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 localhost:7880"
    echo "  $0 your-app.up.railway.app:7880"
    echo "  $0 your-app.up.railway.app:7880 devkey APIfVx..."
    echo ""
    exit 1
fi

SERVER_URL="$1"
API_KEY="${2:-devkey}"
API_SECRET="${3:-APIfVxKzBnLQDH8WtBEULCJ7QZcqFcGBmPvL3YmJvHF}"

# Remove protocol if present
SERVER_URL="${SERVER_URL#http://}"
SERVER_URL="${SERVER_URL#https://}"
SERVER_URL="${SERVER_URL#ws://}"
SERVER_URL="${SERVER_URL#wss://}"

echo -e "${BLUE}Testing server: ${SERVER_URL}${NC}"
echo -e "${BLUE}API Key: ${API_KEY}${NC}"
echo ""

# Test 1: HTTP Endpoint
echo -e "${YELLOW}[1/3] Testing HTTP endpoint...${NC}"
if curl -s -f "http://${SERVER_URL}" > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ HTTP endpoint is accessible${NC}"
    HTTP_SUCCESS=true
else
    echo -e "${RED}   ❌ HTTP endpoint is not accessible${NC}"
    echo -e "${YELLOW}   Trying HTTPS...${NC}"
    if curl -s -f "https://${SERVER_URL}" > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ HTTPS endpoint is accessible${NC}"
        HTTP_SUCCESS=true
    else
        echo -e "${RED}   ❌ HTTPS endpoint is not accessible${NC}"
        HTTP_SUCCESS=false
    fi
fi
echo ""

# Test 2: Port connectivity
echo -e "${YELLOW}[2/3] Testing port connectivity...${NC}"
HOST=$(echo $SERVER_URL | cut -d':' -f1)
PORT=$(echo $SERVER_URL | cut -d':' -f2)
if [ "$PORT" == "$HOST" ]; then
    PORT="7880"
fi

if command -v nc > /dev/null 2>&1; then
    if nc -zv -w 5 "$HOST" "$PORT" 2>&1 | grep -q succeeded; then
        echo -e "${GREEN}   ✅ Port ${PORT} is reachable${NC}"
    else
        echo -e "${RED}   ❌ Port ${PORT} is not reachable${NC}"
        echo -e "${YELLOW}   Make sure the port is exposed in Railway${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  netcat not installed, skipping port test${NC}"
fi
echo ""

# Test 3: Generate test token
echo -e "${YELLOW}[3/3] Generating test token...${NC}"
if command -v livekit-cli > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ livekit-cli found${NC}"

    # Generate token
    TOKEN=$(livekit-cli token create \
        --api-key "$API_KEY" \
        --api-secret "$API_SECRET" \
        --room test-room \
        --identity test-user \
        --valid-for 1h 2>&1)

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✅ Token generated successfully${NC}"
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}Test Token (valid for 1 hour):${NC}"
        echo "$TOKEN"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo -e "${RED}   ❌ Failed to generate token${NC}"
        echo "$TOKEN"
    fi
else
    echo -e "${YELLOW}   ⚠️  livekit-cli not installed${NC}"
    echo -e "${YELLOW}   Install with: npm install -g livekit-cli${NC}"
fi
echo ""

# Summary
echo "╔══════════════════════════════════════════════════╗"
echo "║              Connection Test Summary             ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

if [ "$HTTP_SUCCESS" = true ]; then
    echo -e "${GREEN}✅ Your LiveKit server is accessible!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Use the generated token above to test with:"
    echo "     https://meet.livekit.io/"
    echo ""
    echo "  2. Server URL for WebSocket:"
    echo "     ws://${SERVER_URL} (or wss:// for HTTPS)"
    echo ""
    echo "  3. API Credentials:"
    echo "     Key: ${API_KEY}"
    echo "     Secret: ${API_SECRET:0:10}..."
else
    echo -e "${RED}❌ Cannot connect to LiveKit server${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Verify the server URL is correct"
    echo "  2. Check Railway deployment status"
    echo "  3. Ensure port 7880 is exposed in Railway"
    echo "  4. Check Railway logs for errors"
    echo "  5. Try with Railway's public URL (not localhost)"
fi
echo ""

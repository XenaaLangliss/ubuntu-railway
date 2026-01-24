#!/bin/bash

# LiveKit Startup Script for Railway Deployment
# This script initializes and starts the LiveKit server

set -e

echo "========================================"
echo "LiveKit Server Initialization"
echo "========================================"

# Configuration directory
LIVEKIT_DIR="/opt/livekit"
CONFIG_FILE="$LIVEKIT_DIR/livekit.yaml"
COMPOSE_FILE="$LIVEKIT_DIR/docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Navigate to LiveKit directory
cd "$LIVEKIT_DIR" || exit 1

echo -e "${GREEN}[1/5] Checking configuration...${NC}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found at $CONFIG_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}[2/5] Checking Docker daemon...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${YELLOW}Docker daemon not running. Starting Docker...${NC}"
    dockerd > /var/log/docker.log 2>&1 &
    sleep 5
fi

echo -e "${GREEN}[3/5] Pulling latest LiveKit image...${NC}"
docker compose pull

echo -e "${GREEN}[4/5] Starting LiveKit server...${NC}"
docker compose up -d

echo -e "${GREEN}[5/5] Checking server status...${NC}"
sleep 3

if docker ps | grep -q livekit; then
    echo ""
    echo -e "${GREEN}========================================"
    echo "LiveKit Server Started Successfully!"
    echo "========================================${NC}"
    echo ""
    echo "Server Information:"
    echo "  - HTTP Port: 7880"
    echo "  - TURN/TCP Port: 7881"
    echo "  - WebRTC/UDP Port: 7882"
    echo "  - RTP Ports: 50000-60000"
    echo ""
    echo "Useful Commands:"
    echo "  - View logs: docker logs -f livekit"
    echo "  - Stop server: docker compose down"
    echo "  - Restart server: docker compose restart"
    echo "  - Check status: docker ps"
    echo ""
    echo -e "${YELLOW}WARNING: Update API keys in $CONFIG_FILE for production!${NC}"
    echo ""
else
    echo -e "${RED}Failed to start LiveKit server${NC}"
    echo "Check logs with: docker logs livekit"
    exit 1
fi

# LiveKit Railway Deployment Guide

This repository provides **two deployment options** for LiveKit on Railway:

1. **Production LiveKit Server** (Recommended) - Direct LiveKit deployment
2. **Development VM** - Ubuntu VM with web terminal for testing

## Option 1: Production LiveKit Server (Recommended)

This is the **simplest and recommended approach** for Railway deployments. It runs LiveKit server directly without Docker-in-Docker.

### Quick Deploy

1. **Rename railway.production.json to railway.json**
   ```bash
   mv railway.production.json railway.json
   ```

2. **Configure in Railway Dashboard**
   - Go to your Railway project
   - Settings → Deploy → Deploy from GitHub
   - Select this repository

3. **Set Environment Variables** (Optional)
   ```
   LIVEKIT_API_KEY=<generate-new-key>
   LIVEKIT_API_SECRET=<generate-new-secret>
   ```

4. **Generate Production Keys**
   ```bash
   docker run --rm livekit/livekit-server generate-keys
   ```

5. **Update livekit-config.yaml**
   - Replace the default API keys in `livekit-production.yaml`
   - Copy to `livekit-config.yaml` or update directly

6. **Expose Required Ports in Railway**
   Railway automatically exposes HTTP ports, but for LiveKit you need:
   - **7880** (HTTP/WebSocket) - Primary port
   - **7881** (TURN/TCP) - Optional but recommended
   - **7882** (WebRTC/UDP) - For direct UDP connections
   - **50000-60000** (RTP) - Media traffic

   Note: Railway's networking layer handles most connectivity. Start with port 7880 only.

### Testing Your Deployment

After deployment:

```bash
# Get your Railway URL (example: https://your-app.up.railway.app)
# LiveKit will be accessible at: ws://your-app.up.railway.app:7880
# Or with Railway's proxy: wss://your-app.up.railway.app

# Test with LiveKit CLI
npm install -g livekit-cli

# Create a test token
livekit-cli token create \
  --api-key <your-key> \
  --api-secret <your-secret> \
  --room test-room \
  --identity user1 \
  --valid-for 24h
```

### Advantages
✅ Simple deployment - no Docker-in-Docker complexity
✅ Better performance - direct process execution
✅ Lower resource usage
✅ Faster startup time
✅ Works perfectly with Railway's networking
✅ Production-ready out of the box

### Files Used
- `Dockerfile.livekit` - Production Dockerfile
- `livekit-production.yaml` - Production configuration
- `railway.production.json` - Railway deployment config

---

## Option 2: Development VM (Current Setup)

This provides a full Ubuntu VM with web terminal access via ttyd. Useful for debugging and development.

### Current Status

Your current deployment uses this option. The logs show ttyd is running successfully on port 8080, providing a web terminal.

### Limitations on Railway

⚠️ **Docker-in-Docker doesn't work on Railway without privileged mode**

The current `Dockerfile` attempts to run Docker daemon inside the container, which Railway doesn't support by default. This means:
- ✅ Web terminal (ttyd) works perfectly
- ❌ Docker daemon won't start automatically
- ❌ Can't run `docker-compose` inside the container

### What Works
- Web terminal access via Railway URL
- All system tools (wget, curl, git, python3)
- Manual software installation
- File editing and exploration

### What Doesn't Work
- Docker-in-Docker (requires privileged mode)
- Running containerized LiveKit via docker-compose
- Automated LiveKit startup script

### How to Use

1. Access the web terminal via your Railway URL
2. Login with credentials from Railway environment variables:
   - Username: `$USERNAME`
   - Password: `$PASSWORD`

3. Manual LiveKit installation (if needed):
   ```bash
   # Download LiveKit binary
   wget https://github.com/livekit/livekit/releases/download/v1.5.3/livekit_1.5.3_linux_amd64.tar.gz
   tar -xzf livekit_1.5.3_linux_amd64.tar.gz

   # Run LiveKit directly
   ./livekit-server --config /opt/livekit/livekit.yaml --bind 0.0.0.0
   ```

### Files Used
- `Dockerfile` - Ubuntu VM with ttyd
- `livekit-config.yaml` - LiveKit configuration
- `start-livekit.sh` - Startup script (won't work without Docker)

---

## Recommendation

**For Railway POC/Production: Use Option 1 (Production LiveKit Server)**

The VM approach (Option 2) is currently deployed but has limitations on Railway. Switch to Option 1 for:
- Simpler deployment
- Better Railway compatibility
- Production-ready setup
- Lower resource usage

## Migration Steps (VM → Production)

1. **Update railway.json**:
   ```bash
   cp railway.production.json railway.json
   ```

2. **Generate new API keys**:
   ```bash
   docker run --rm livekit/livekit-server generate-keys
   ```

3. **Update configuration**:
   - Edit `livekit-production.yaml`
   - Replace API keys
   - Save as `livekit-config.yaml` or update Dockerfile.livekit to use it

4. **Commit and push**:
   ```bash
   git add railway.json livekit-production.yaml
   git commit -m "Switch to production LiveKit deployment"
   git push
   ```

5. **Railway will auto-redeploy** with the new configuration

## Port Configuration on Railway

### For Production LiveKit (Option 1)

Railway's networking typically works like this:

1. **Primary Port (7880)**: Railway can expose this with TCP proxy
2. **UDP Ports**: Railway supports UDP, but configuration may vary
3. **Port Ranges**: May require Railway Pro plan or specific configuration

**Simplified Setup**:
- Start with just port 7880 exposed
- LiveKit will work for most scenarios
- Add TURN (7881) if clients are behind strict firewalls
- UDP (7882, 50000-60000) only needed for optimal performance

### Checking Exposed Ports

In Railway Dashboard:
1. Go to your service
2. Settings → Networking
3. View public hostname and ports
4. Configure custom port mappings if needed

## Environment Variables Reference

### Required
```bash
# For VM option (Dockerfile)
PORT=3000              # ttyd web terminal port
USERNAME=admin         # Web terminal username
PASSWORD=<secure-pass> # Web terminal password

# For Production option (Dockerfile.livekit)
# All optional - defaults in livekit-config.yaml
LIVEKIT_API_KEY=<your-api-key>
LIVEKIT_API_SECRET=<your-api-secret>
```

### Optional
```bash
# Redis (for scaling)
REDIS_HOST=redis.railway.internal
REDIS_PORT=6379

# Webhook
LIVEKIT_WEBHOOK_URL=https://your-app.com/webhook
LIVEKIT_WEBHOOK_KEY=<secret>

# Custom domain
LIVEKIT_DOMAIN=livekit.yourdomain.com
```

## Troubleshooting

### "Can't connect to LiveKit"
- Verify the Railway URL is correct
- Check if port 7880 is exposed
- Ensure API keys match between client and server
- Try `ws://` if `wss://` doesn't work (and vice versa)

### "Container keeps restarting"
- Check Railway logs for errors
- Verify `livekit-config.yaml` syntax
- Ensure all COPY'd files exist in repository

### "High resource usage"
- LiveKit is CPU/memory intensive with many users
- Monitor Railway metrics
- Consider upgrading Railway plan for production

## Cost Estimation (Railway)

**Hobby Plan** ($5/month):
- Good for development and small POCs
- Limited resources (512MB RAM, 1 vCPU)
- May struggle with multiple concurrent users

**Pro Plan** ($20/month):
- Recommended for production POC
- Better resources and scaling
- More reliable for real-time traffic

**Enterprise**:
- Contact Railway for high-scale deployments
- Custom resource allocation

## Next Steps

1. ✅ Choose deployment option (Production recommended)
2. ✅ Generate new API keys
3. ✅ Configure Railway
4. ✅ Test connectivity
5. ✅ Build your application using LiveKit SDKs
6. ✅ Monitor and scale as needed

## Resources

- [LiveKit Documentation](https://docs.livekit.io/)
- [LiveKit Server GitHub](https://github.com/livekit/livekit)
- [Railway Documentation](https://docs.railway.app/)
- [LiveKit Examples](https://github.com/livekit-examples)

## Support

- **LiveKit Issues**: [LiveKit Discord](https://livekit.io/discord)
- **Railway Issues**: [Railway Discord](https://discord.gg/railway)
- **This Repo**: Open a GitHub issue

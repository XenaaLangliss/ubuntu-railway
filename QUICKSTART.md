# LiveKit on Railway - Quick Start Guide

This guide will help you get LiveKit up and running on Railway in minutes.

## Prerequisites

- A Railway account ([sign up here](https://railway.app/))
- Basic understanding of environment variables
- (Optional) A domain name for production deployment

## Step 1: Deploy to Railway

1. Click the "Deploy on Railway" button in the README
2. Fork/import this repository to your Railway account
3. Railway will automatically detect the `Dockerfile` and start building

## Step 2: Configure Environment Variables

In Railway's dashboard, add these environment variables:

```
PORT=3000
USERNAME=admin
PASSWORD=your-secure-password-here
```

For production, also add:
```
LIVEKIT_API_KEY=<generated-key>
LIVEKIT_API_SECRET=<generated-secret>
```

Generate production keys later using:
```bash
docker run --rm livekit/livekit-server generate-keys
```

## Step 3: Wait for Deployment

- Railway will build the Docker image (this takes 3-5 minutes)
- Once deployed, you'll get a public URL (e.g., `your-app.up.railway.app`)

## Step 4: Access Web Terminal

1. Open your Railway-provided URL in a browser
2. Log in with the USERNAME and PASSWORD you set
3. You'll see a web-based Ubuntu terminal

## Step 5: Start LiveKit Server

In the web terminal, run:

```bash
cd /opt/livekit
sudo ./start-livekit.sh
```

You should see:
```
========================================
LiveKit Server Started Successfully!
========================================

Server Information:
  - HTTP Port: 7880
  - TURN/TCP Port: 7881
  - WebRTC/UDP Port: 7882
  - RTP Ports: 50000-60000
```

## Step 6: Configure Railway Ports

In Railway's settings, expose these ports:
- **7880** - HTTP/WebSocket API (required)
- **7881** - TURN/TCP
- **7882** - WebRTC/UDP
- **50000-60000** - RTP range (for media)

Railway will provide public URLs for exposed ports.

## Step 7: Test Your LiveKit Server

### Using LiveKit CLI

```bash
# Install LiveKit CLI
npm install -g livekit-cli

# Test connection (replace with your Railway URL)
livekit-cli token create \
  --api-key devkey \
  --api-secret APIfVxKzBnLQDH8WtBEULCJ7QZcqFcGBmPvL3YmJvHF \
  --room my-room \
  --identity user1 \
  --valid-for 24h
```

### Using LiveKit Example App

Visit [LiveKit Meet](https://meet.livekit.io/) and enter:
- **URL:** `ws://your-railway-url:7880` (or wss:// if you have SSL)
- **Token:** Generated from the CLI command above

## Step 8: Production Configuration

### Generate New API Keys

**CRITICAL:** Change the default API keys!

```bash
docker run --rm livekit/livekit-server generate-keys
```

This outputs:
```
API Key: APIxxxxxxxxx
API Secret: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Update these in:
1. Railway environment variables
2. `/opt/livekit/livekit.yaml`

Restart LiveKit:
```bash
cd /opt/livekit
docker compose restart
```

### Configure Domain (Optional but Recommended)

1. In Railway, go to Settings > Networking
2. Add your custom domain (e.g., `livekit.yourdomain.com`)
3. Update DNS records as instructed by Railway
4. Railway will automatically provision SSL certificates
5. Update `livekit-config.yaml` with your domain

## Monitoring and Logs

### View LiveKit Logs
```bash
docker logs -f livekit
```

### Check Server Status
```bash
docker ps
```

### Resource Usage
```bash
docker stats livekit
```

## Common Issues

### "Docker daemon not running"
```bash
sudo service docker start
# or
sudo dockerd &
```

### "Port already in use"
```bash
# Check what's using the port
sudo lsof -i :7880

# Stop the conflicting service or change LiveKit ports
```

### "Can't connect to LiveKit"
- Verify ports are exposed in Railway
- Check firewall rules
- Ensure API keys match
- Try using IP address instead of domain

## Next Steps

1. **Build Your Application:** Use LiveKit's SDKs for [JavaScript](https://docs.livekit.io/client-sdk-js/), [React](https://docs.livekit.io/client-sdk-react/), [iOS](https://docs.livekit.io/client-sdk-swift/), [Android](https://docs.livekit.io/client-sdk-android/), etc.

2. **Configure Webhooks:** Set up event notifications in `livekit-config.yaml`

3. **Add Redis:** For horizontal scaling, add Redis to your Railway project

4. **Enable TURN:** For better connectivity, configure a TURN server

5. **Monitor Performance:** Use Railway's built-in metrics or integrate external monitoring

## Useful Commands

```bash
# Start LiveKit
cd /opt/livekit && ./start-livekit.sh

# Stop LiveKit
cd /opt/livekit && docker compose down

# Restart LiveKit
cd /opt/livekit && docker compose restart

# View logs
docker logs -f livekit

# Edit configuration
nano /opt/livekit/livekit.yaml

# Check Docker status
docker ps -a

# Generate new API keys
docker run --rm livekit/livekit-server generate-keys
```

## Support

- **LiveKit Docs:** https://docs.livekit.io/
- **LiveKit Discord:** https://livekit.io/discord
- **Railway Docs:** https://docs.railway.app/
- **Railway Discord:** https://discord.gg/railway

## Security Reminders

- ✅ Change default USERNAME and PASSWORD
- ✅ Generate new API keys for production
- ✅ Use HTTPS/WSS in production
- ✅ Keep LiveKit updated
- ✅ Monitor logs for suspicious activity
- ✅ Implement rate limiting in your application

---

**Ready to build?** Check out [LiveKit Examples](https://github.com/livekit-examples) for sample applications!

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu)
![Docker](https://img.shields.io/badge/Docker-Supported-blue?logo=docker)
![LiveKit](https://img.shields.io/badge/LiveKit-Ready-00A86B?logo=webrtc)

# Ubuntu-Railway with LiveKit

A pre-configured Ubuntu 22.04 VM with LiveKit server for real-time video/audio communication, ready for deployment on Railway as a proof of concept.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/template/4lvigd?referralCode=zkQBwB)

## Description

This project combines the official [Ubuntu 22.04](https://hub.docker.com/_/ubuntu) image with [LiveKit](https://livekit.io/) - an open-source WebRTC infrastructure for building real-time video, audio, and data experiences. It includes a web-based terminal via [ttyd](https://github.com/tsl0922/ttyd) for easy management and configuration.

### Features

- 🐧 Official Ubuntu 22.04 LTS base
- 🎥 LiveKit server pre-configured for production deployment
- 🔒 Password-protected web terminal
- 💻 Neofetch display on login
- 🐳 Docker and Docker Compose pre-installed
- 🚀 One-command LiveKit startup script

## Environment Variables

### Required Variables

- **PORT:** The port on which the ttyd web terminal will listen (default: 3000)
- **USERNAME:** The username for the web terminal login
- **PASSWORD:** The password for the web terminal login

### Optional LiveKit Variables

- **LIVEKIT_API_KEY:** API key for LiveKit authentication (default: devkey)
- **LIVEKIT_API_SECRET:** API secret for LiveKit authentication
- **LIVEKIT_DOMAIN:** Your domain for production deployment with SSL
- **TURN_DOMAIN:** TURN server domain (for NAT traversal)

**IMPORTANT:** For production deployments, you MUST change the default API keys. Generate new keys with:
```bash
docker run --rm livekit/livekit-server generate-keys
```

See `.env.example` for a complete list of configuration options.

## Deploy and Host

### Quick Deploy to Railway

1. Click the deploy button above to deploy this template to Railway
2. Set the required environment variables (PORT, USERNAME, PASSWORD)
3. Wait for the deployment to complete (takes 3-5 minutes)
4. Access the web terminal via the Railway-provided domain
5. Start LiveKit server from the terminal (see usage instructions below)

### Manual Deployment

1. Clone this repository
2. Copy `.env.example` to `.env` and update the values
3. Build and deploy to Railway using the Railway CLI or GitHub integration

## LiveKit Server Usage

### Starting LiveKit

Once deployed and logged into the web terminal, start the LiveKit server:

```bash
cd /opt/livekit
sudo ./start-livekit.sh
```

The script will:
1. Check the configuration
2. Start Docker daemon if needed
3. Pull the latest LiveKit image
4. Start the LiveKit server
5. Display server information and useful commands

### LiveKit Ports

The following ports are exposed for LiveKit:
- **7880:** HTTP/WebSocket API
- **7881:** TURN/TCP (for NAT traversal)
- **7882:** WebRTC/UDP (media streaming)
- **50000-60000:** RTP ports (media traffic)

### Useful Commands

```bash
# View LiveKit logs
docker logs -f livekit

# Stop LiveKit server
cd /opt/livekit && docker compose down

# Restart LiveKit server
cd /opt/livekit && docker compose restart

# Check server status
docker ps | grep livekit
```

### Configuration

LiveKit configuration is located at `/opt/livekit/livekit.yaml`. Edit this file to customize:
- Port settings
- Room configuration
- API keys (REQUIRED for production!)
- TURN server settings
- Webhook endpoints
- Logging preferences

After editing, restart the server for changes to take effect.

## Why Deploy

- 🎥 Self-hosted real-time video/audio infrastructure
- 🌐 Quick access to an Ubuntu terminal from anywhere
- 🔧 No local installation required
- 📚 Perfect for testing LiveKit applications
- ⚡ Lightweight and fast
- 🔐 Full control over your WebRTC infrastructure

## Common Use Cases

- Building video conferencing applications
- Real-time audio/video streaming
- Interactive live streaming platforms
- Remote collaboration tools
- WebRTC testing and development
- IoT video/audio monitoring
- Testing shell scripts and Linux commands
- Remote development environment

## Dependencies for Deployment

- Docker (handled by Railway)
- Railway account
- Domain name (optional, for production with SSL/TLS)

### Included Software

This template automatically installs:
- **System Tools:** wget, curl, git, ca-certificates
- **Languages:** Python 3 with pip
- **Container Runtime:** Docker CE, containerd, Docker Compose
- **Terminal:** ttyd (web-based terminal)
- **Monitoring:** neofetch
- **LiveKit:** Latest LiveKit server via Docker

## Production Deployment Checklist

Before deploying LiveKit to production:

- [ ] Generate new API keys using `docker run --rm livekit/livekit-server generate-keys`
- [ ] Update `livekit-config.yaml` with your production API keys
- [ ] Configure a domain name and DNS records
- [ ] Set up SSL/TLS certificates (use Let's Encrypt or Railway's automatic HTTPS)
- [ ] Configure TURN server for better connectivity behind NATs/firewalls
- [ ] Set up monitoring and logging
- [ ] Configure webhooks for event notifications (optional)
- [ ] Review and adjust room settings (max participants, timeouts, etc.)
- [ ] Set up Redis for multi-instance deployments (optional)
- [ ] Test connectivity from various networks and devices

## About Hosting on Railway

Railway provides hosting with:
- $5 free credit monthly (new users)
- Automatic HTTPS with custom domains
- Environment variable management
- Easy deployment from GitHub
- Built-in metrics and logging
- Scalable infrastructure

**Note:** LiveKit is resource-intensive. Monitor your usage and consider upgrading your Railway plan for production deployments with multiple concurrent users.

## Security Considerations

1. **Change Default Credentials:** Always change the default USERNAME and PASSWORD
2. **Generate New API Keys:** Never use the default LiveKit API keys in production
3. **Use HTTPS:** Enable SSL/TLS for all production deployments
4. **Firewall Rules:** Only expose necessary ports
5. **Regular Updates:** Keep LiveKit and system packages updated
6. **Access Control:** Implement proper authentication in your application
7. **Rate Limiting:** Configure rate limits to prevent abuse

## Troubleshooting

### LiveKit won't start
- Check Docker daemon: `service docker status`
- View logs: `docker logs livekit`
- Verify configuration: `cat /opt/livekit/livekit.yaml`

### Can't connect to LiveKit
- Ensure all required ports are exposed in Railway
- Check firewall settings
- Verify API keys match between client and server
- Test with LiveKit's example applications

### Performance issues
- Monitor resource usage: `htop` or `docker stats`
- Check Railway plan limits
- Consider enabling Redis for caching
- Review room configuration settings

## Additional Resources

- [LiveKit Documentation](https://docs.livekit.io/)
- [LiveKit GitHub Repository](https://github.com/livekit/livekit)
- [Railway Documentation](https://docs.railway.app/)
- [Docker Documentation](https://docs.docker.com/)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Support

For issues and questions:
- LiveKit: [LiveKit Discord](https://livekit.io/discord)
- Railway: [Railway Discord](https://discord.gg/railway)
- This project: Open an issue on GitHub

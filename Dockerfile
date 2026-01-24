FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    wget \
    curl \
    git \
    python3 \
    python3-pip \
    neofetch \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install ttyd for web terminal
RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

# Create LiveKit directory
RUN mkdir -p /opt/livekit

# Copy LiveKit configuration files
COPY livekit-config.yaml /opt/livekit/livekit.yaml
COPY docker-compose.livekit.yml /opt/livekit/docker-compose.yml
COPY start-livekit.sh /opt/livekit/start-livekit.sh
RUN chmod +x /opt/livekit/start-livekit.sh

# Setup bash profile
RUN echo "neofetch" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc && \
    echo "echo ''" >> /root/.bashrc && \
    echo "echo '=== LiveKit Server Info ==='" >> /root/.bashrc && \
    echo "echo 'LiveKit config: /opt/livekit/livekit.yaml'" >> /root/.bashrc && \
    echo "echo 'Start LiveKit: cd /opt/livekit && ./start-livekit.sh'" >> /root/.bashrc && \
    echo "echo 'View logs: docker logs -f livekit'" >> /root/.bashrc && \
    echo "echo '==========================='" >> /root/.bashrc && \
    echo "echo ''" >> /root/.bashrc

# Expose ports
# $PORT - ttyd web terminal
# 7880 - LiveKit HTTP
# 7881 - LiveKit TURN/TLS
# 7882 - LiveKit WebRTC/UDP
# 50000-60000 - LiveKit RTP
EXPOSE $PORT 7880 7881 7882/udp

CMD ["/bin/bash", "-c", "\
    echo \"export PS1='\\[\\033[01;32m\\]$USERNAME@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '\" >> /root/.bashrc && \
    dockerd > /var/log/docker.log 2>&1 & \
    sleep 5 && \
    /bin/ttyd -p $PORT -c $USERNAME:$PASSWORD /bin/bash"]

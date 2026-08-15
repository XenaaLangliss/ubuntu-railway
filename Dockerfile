FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl git python3 python3-pip neofetch openssh-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "neofetch" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc

EXPOSE $PORT

CMD ["sh", "-c", "ssh-keygen -A && mkdir -p /run/sshd && /usr/sbin/sshd -D"]

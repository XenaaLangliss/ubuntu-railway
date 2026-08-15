FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl git python3 python3-pip neofetch openssh-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "neofetch" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY docker_key.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

EXPOSE $PORT
CMD ["sh", "-c", "ssh-keygen -A && mkdir -p /run/sshd && /usr/sbin/sshd -D"]

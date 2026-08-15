FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl git python3 python3-pip neofetch openssh-server sudo tmux nano && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear usuario claude con su home
RUN useradd -m -s /bin/bash claude && \
    usermod -aG sudo claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/claude/proyectos && \
    chown -R claude:claude /home/claude

# SSH: solo pubkey, sin root, sin password
RUN mkdir -p /run/sshd && \
    mkdir -p /home/claude/.ssh && \
    chmod 700 /home/claude/.ssh && \
    chown claude:claude /home/claude/.ssh

RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "AllowUsers claude" >> /etc/ssh/sshd_config

RUN echo "neofetch" >> /home/claude/.bashrc && \
    echo "cd /home/claude/proyectos" >> /home/claude/.bashrc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE $PORT

CMD ["/entrypoint.sh"]

#!/bin/bash
set -e

ssh-keygen -A

if [ -n "$SSH_PUBLIC_KEY" ]; then
    mkdir -p /home/claude/.ssh
    echo "$SSH_PUBLIC_KEY" > /home/claude/.ssh/authorized_keys
    chmod 700 /home/claude/.ssh
    chmod 600 /home/claude/.ssh/authorized_keys
    chown -R claude:claude /home/claude/.ssh
else
    echo "ERROR: falta la variable SSH_PUBLIC_KEY"
    exit 1
fi

mkdir -p /home/claude/proyectos
chown claude:claude /home/claude/proyectos

# Lanzar Claude Code en modo remote-control dentro de tmux, como el usuario claude
if [ -x "/home/claude/.local/bin/claude" ]; then
    su - claude -c "tmux new-session -d -s claude-session 'cd /home/claude/proyectos && /home/claude/.local/bin/claude remote-control'" \
        && echo "Sesión tmux 'claude-session' iniciada." \
        || echo "AVISO: no se pudo iniciar tmux para claude."
else
    echo "AVISO: /home/claude/.local/bin/claude no existe — omitiendo tmux."
fi

exec /usr/sbin/sshd -D -e -p 22

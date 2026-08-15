#!/bin/bash
set -e

ssh-keygen -A

if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "$SSH_PUBLIC_KEY" > /home/claude/.ssh/authorized_keys
    chmod 600 /home/claude/.ssh/authorized_keys
    chown claude:claude /home/claude/.ssh/authorized_keys
else
    echo "ERROR: falta la variable SSH_PUBLIC_KEY"
    exit 1
fi

exec /usr/sbin/sshd -D -e -p 22

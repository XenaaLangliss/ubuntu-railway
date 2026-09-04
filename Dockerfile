FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget curl git python3 python3-pip neofetch && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

RUN echo "neofetch" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc

EXPOSE $PORT

CMD ["/bin/bash", "-c", "\
    echo \"export PS1='\\[\\033[01;32m\\]$USERNAME@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '\" >> /root/.bashrc && \
    /bin/ttyd -p $PORT -c $USERNAME:$PASSWORD /bin/bash"]

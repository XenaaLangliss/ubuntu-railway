FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget curl git python3 python3-pip neofetch
    curl -sSf https://sshx.io/get | sh -s run

RUN wget -qO /bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 && \
    chmod +x /bin/ttyd

RUN echo "neofetch" >> /root/.bashrc

EXPOSE $PORT

RUN echo $CREDENTIAL > /tmp/debug

CMD ["/bin/bash", "-c", "/bin/ttyd -p $PORT -c $USERNAME:$PASSWORD /bin/bash"]

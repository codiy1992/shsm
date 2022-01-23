FROM amd64/alpine:latest

LABEL Author=Codiy \
      Mail=mail@codiy.net

ENV LC_ALL=en_US.UTF-8

RUN apk add --no-cache \
        git \
        vim \
        bash \
        gnupg \
        ca-certificates \
        docker \
        docker-compose \
        openssh-client

WORKDIR /root

#!/bin/bash

if ! [ -x "$(command -v make)" ]; then
    if ! [ -x "$(command -v docker-compose)" ]; then
        docker build -t shsm
        docker run -v ${PWD}:/root \
            -v ${HOME}/.gnupg/shsm.sec.key:/root/.gnupg/secret.key \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --rm -it shsm bash --login
    else
        docker-compose run --rm shsm bash --login
    fi
else
    make
fi

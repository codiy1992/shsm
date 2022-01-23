#!/bin/bash

if ! [ -x "$(command -v make)" ]; then
    if ! [ -x "$(command -v docker-compose)" ]; then
        docker build -t shsm
        docker run -v ${PWD}:/root --rm -it shsm bash --login
    else
        docker-compose run --rm shsm bash --login
    fi
else
    make
fi

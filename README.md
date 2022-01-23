# shcm
Self Hosted Container Management

## Requirements

* Docker

## Setup without git installed

```shell
docker run --rm -v ~/shsm:/code amd64/alpine /bin/sh -c 'apk add git openssh-client; \
mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts; \
git clone https://github.com/codiy1992/shsm.git /code; \
sed "s/^\turl = http.*/\turl = git@github.com:codiy1992/shsm.git/" /code/.git/config'
```

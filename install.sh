#/bin/sh

docker run --rm -v ${PWD}/shsm:/code alpine \
    /bin/sh -c 'apk add git openssh-client; \
        mkdir -p ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts; \
        git clone https://github.com/codiy1992/shsm.git /code; \
        sed -i "s/^\turl = http.*/\turl = git@github\.com:codiy1992\/shsm\.git/" /code/.git/config'

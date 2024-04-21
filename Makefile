C?=shsm
S?=/bin/bash

.SILENT:
default:
	docker-compose run --rm ${C} ${S} --login

bash:
	[[ "`docker images -q shsm:latest 2> /dev/null`" != "" ]] || docker build -t shsm .
	docker run -v ${PWD}:/root \
		-v ${HOME}/.gnupg/shsm.sec.key:/root/.gnupg/secret.key \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--rm -it shsm bash --login

build:
	docker-compose build ${C}

logs:
	docker-compose logs -f ${C}


C?=shsm
S?=/bin/bash

.SILENT:
default:
	docker-compose run --rm ${C} ${S} --login

build:
	docker-compose build ${C}

up:
	docker-compose up -d ${C}

down:
	docker-compose down

stop:
	docker-compose stop ${C}

restart:
	docker-compose stop ${C} && docker-compose up -d ${C}

bash:
	docker-compose exec ${C} ${S}

logs:
	docker-compose logs -f ${C}


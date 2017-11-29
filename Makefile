FIG=docker-compose
CONSOLE=bin/console
RUN=$(FIG) run --rm web_back
EXEC=$(FIG) exec web_back

.PHONY: install back front help com
.DEFAULT_GOAL :=help

help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

stp:           ## stop container docker
stp: docker-compose.yml
	$(FIG) stop

ps: ## show service docker launcher
ps: docker-compose.yml
	docker ps

install:        ## launch project
install: stop start ps

dkUbuntu:           ## Launch container os
dkUbuntu:
	docker exec -ti dkUbuntu bash

jenkins:          ## Launch container jenkins
jenkins:
	docker exec -ti jenkins_1 bash

sonar:          ## Launch container sonar
sonar:
	docker exec -ti sonar_1 bash

sql_sonar:          ## Launch container mysql sonar
sql_sonar:
	docker exec -ti sql_sonar_ bash

cc:             ## Clear the cache in dev env
cc:
	$(RUN) $(CONSOLE) cache:clear --no-warmup
	$(RUN) $(CONSOLE) cache:warmup
	$(RUN) $(CONSOLE) doctrine:cache:clear-metadata

##
## Project setup
##---------------------------------------------------------------------------

start:          ## Install and start the project
start: build up

stop:           ## Remove docker containers
	$(FIG) kill
	$(FIG) rm -v --force

reset:          ## Reset the whole project
reset: stop start ps

clear:          ## Remove all the cache, the logs and the sessions
clear: perm
	-$(EXEC) rm -rf var/cache/*
	-$(EXEC) rm -rf var/sessions/*
	-$(EXEC) $(CONSOLE) redis:flushall -n
	-$(EXEC) $(CONSOLE) doctrine:cache:clear-metadata
	rm -rf var/logs/*
	rm -rf web/built

clean:          ## Clear and remove dependencies
clean: clear
	rm -rf vendor node_modules


# Internal rules

build:
	$(FIG) build

up:
	$(FIG) up -d

perm:
	-$(EXEC) chmod -R 777 var


# Rules from files

vendor: composer.lock
	@$(RUN) composer install

composer.lock: back/composer.json
	@echo compose.lock is not up to date.

back/app/config/parameters.yml: back/app/config/parameters.yml.dist
	@$(RUN) composer run-script post-install-cmd

##
## Tests
##---------------------------------------------------------------------------

test:           ## Run the PHP
test: tu

tu:             ## Run the PHP unit tests
tu: vendor
	$(EXEC) vendor/bin/phpunit --exclude-group functional || true

lint:           ## Run lint on Twig, YAML and Javascript files
lint: ls ly lt

ls:             ## Lint Symfony (Twig and YAML) files
ls: ly lt

ly:
	$(RUN) $(CONSOLE) lint:yaml app/config

lt:
	$(RUN) $(CONSOLE) lint:twig templates

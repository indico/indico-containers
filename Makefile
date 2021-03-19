# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

include .env

CERT_DAYS?=365

.DEFAULT_GOAL=build

.PHONY: volumes
volumes:
	@docker volume inspect $(ARCHIVE_VOLUME_HOST) >/dev/null 2>&1 || docker volume create --name $(ARCHIVE_VOLUME_HOST)
	@docker volume inspect $(STATIC_VOLUME_HOST) >/dev/null 2>&1 || docker volume create --name $(STATIC_VOLUME_HOST)
	@docker volume inspect $(CUSTOM_VOLUME_HOST) >/dev/null 2>&1 || docker volume create --name $(CUSTOM_VOLUME_HOST)
	@docker volume inspect $(DB_VOLUME_HOST) >/dev/null 2>&1 || docker volume create --name $(DB_VOLUME_HOST)

# FIXME: doesn't work with different user and admin passwords
secrets/postgres.env:
	@mkdir -p secrets
	@$(eval PASS := $(shell openssl rand -hex 32))
	@echo "Generating postgres password in $@"
	@echo "PGPASSWORD=$(PASS)" > $@
	@echo "POSTGRES_PASSWORD=$(PASS)" >> $@
	@echo "POSTGRESQL_PASSWORD=$(PASS)" >> $@
	@echo "POSTGRESQL_ADMIN_PASSWORD=$(PASS)" >> $@

secrets/secret.env:
	@mkdir -p secrets
	@echo "Generating secret key in $@"
	@echo "SECRET_KEY=$(shell openssl rand -hex 32)" > $@

nginx/secrets/mycert.key: nginx/secrets/mycert.crt

nginx/secrets/mycert.crt:
	@mkdir -p nginx/secrets
	@openssl req -x509 -nodes -days $(CERT_DAYS) -newkey rsa:2048 -keyout \
	nginx/secrets/mycert.key -out nginx/secrets/mycert.crt

.PHONY: build
build: nginx/secrets/mycert.crt nginx/secrets/mycert.key secrets/postgres.env secrets/secret.env volumes
	docker-compose build

.PHONY: purge
purge:
	docker-compose down
	-@docker volume inspect $(ARCHIVE_VOLUME_HOST) >/dev/null 2>&1 && docker volume rm $(ARCHIVE_VOLUME_HOST)
	-@docker volume inspect $(STATIC_VOLUME_HOST) >/dev/null 2>&1 && docker volume rm $(STATIC_VOLUME_HOST)
	-@docker volume inspect $(CUSTOM_VOLUME_HOST) >/dev/null 2>&1 && docker volume rm $(CUSTOM_VOLUME_HOST)
	-@docker volume inspect $(DB_VOLUME_HOST) >/dev/null 2>&1 && docker volume rm $(DB_VOLUME_HOST)

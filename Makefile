SHELL := /bin/bash
AIRFLOW_VERSION ?= stable
COMPOSE := docker compose -f docker-compose.yaml

.NOTPARALLEL:
.PHONY: help _download env setup init up up-examples logs down clean nuke _clean-files

help: ## Display available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_-]+:.*## / {printf "\033[36m%-28s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

_download: # Step 0: Download and configure the latest official Compose file
	@echo "Downloading the latest official Compose file for Airflow $(AIRFLOW_VERSION)"
	@set -eu; temporary=$$(mktemp ./docker-compose.yaml.XXXXXX); \
	trap 'rm -f "$$temporary"' EXIT; \
	curl -fLsS 'https://airflow.apache.org/docs/apache-airflow/$(AIRFLOW_VERSION)/docker-compose.yaml' -o "$$temporary"; \
	python3 scripts/airflow_setup.py compose "$$temporary"; \
	mv "$$temporary" docker-compose.yaml
	@ls -ltr docker-compose.yaml

_env: # Step 0: Set the host UID and preserve or generate a Fernet key
	@python3 scripts/airflow_setup.py compose docker-compose.yaml
	@python3 scripts/airflow_setup.py env
	@mkdir -p dags logs plugins config

setup: _download _env ## Step 1: Download Compose and prepare the local environment

init: ## Step 2: Initialize the Airflow database and default account
	$(COMPOSE) run --rm airflow-init

up: ## Step 3: Initialize and start Airflow with a bare environment
	@python3 scripts/airflow_setup.py examples false
	@$(MAKE) init
	$(COMPOSE) up -d

up-examples: ## Step 3+: Initialize and start Airflow with example DAGs
	@python3 scripts/airflow_setup.py examples true
	@$(MAKE) init
	$(COMPOSE) up -d

logs: ## Step 4: Follow logs from all Compose services
	-$(COMPOSE) logs --follow

down: ## Step 5: Stop containers while retaining volumes and local files
	-$(COMPOSE) stop

_clean-files:
	rm -rvf -- dags logs plugins config

clean: ## Step 6: Remove containers, volumes, and local lab files
	-$(COMPOSE) down --volumes --remove-orphans
	@$(MAKE) _clean-files

nuke: ## Step 7: Remove containers, volumes, generated files, and stack images
	$(COMPOSE) down --volumes --remove-orphans --rmi all
	@$(MAKE) _clean-files

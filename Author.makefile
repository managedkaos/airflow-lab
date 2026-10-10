SHELL := /bin/bash
README_FILES := $(shell find . -name 'README.md' -not -path './.git/*' | sort)
FOOTER_IMAGE := ghcr.io/managedkaos/readme-footer-generator:main

.NOTPARALLEL:
.PHONY: help all spellcheck footer

help: ## Display available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_-]+:.*## / {printf "\033[36m%-28s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: spellcheck footer ## Spell-check READMEs and generate footer links
	@echo "Done."

files:
	@for file in $(README_FILES); do \
		printf '\t%s\n' "$$file"; \
	done

spellcheck: ## Interactively spell-check all README files
	@echo "Spell checking README files..."
	@set -o errexit; for file in $(README_FILES); do \
		printf '\t%s\n' "$$file"; \
		aspell check --mode=markdown --lang=en "$$file"; \
	done

footer: ## Generate navigation footer links for README files
	@echo "Generating footer links for README files..."
	docker pull $(FOOTER_IMAGE)
	docker run --rm --volume "$(CURDIR):/data" $(FOOTER_IMAGE)

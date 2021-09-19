# NixOS Makefile

# Make defaults
# Use commonly available shell
SHELL := bash
# Fail if piped commands fail - critical for CI/etc
.SHELLFLAGS := -o errexit -o nounset -o pipefail -c
# Use one shell for a target, rather than shell per line
.ONESHELL:

all: help

fmt: ## Format *.nix
	find . -name '*.nix' -print | \
		xargs -n 1 -- nixfmt

.PHONY: setup
setup: ## Setup
	# TODO: something better
	git submodule add ~/src/secrets/ secrets

.PHONY: build
build: ## Build latest NixOS configuration
	# rebuild configuration per --flake .#${hostname}
	nixos-rebuild build --flake .#

.PHONY: switch
switch: build ## Build latest and switch
	nixos-rebuild switch --flake .#

.PHONY: update
update: ## Update packages
	echo "Not implemented yet"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



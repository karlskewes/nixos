# NixOS Makefile

SHELL := /usr/bin/env bash -o errexit -o nounset -o pipefail -c

all: help

fmt: ## Format *.nix
	find . -name '*.nix' -print | \
		xargs -n 1 -- nixfmt

.PHONY: setup
setup: ## Setup
	# TODO: something better
	mkdir -p ~/src/nix-extra
	vim ~/src/nix-extra/nixos.nix

.PHONY: build
build: ## Build latest NixOS & home-manager configuration
	# rebuild configuration per --flake .#${hostname}
	nixos-rebuild build --flake .#
	# build home-manager
	nix build .#homeManagerConfigurations.$$(hostname).activationPackage

.PHONY: switch
switch: build ## Build latest and switch
	sudo nixos-rebuild switch --flake .#
	./result/activate

.PHONY: clean
clean: ## Clean old generations
	# home manager
	nix-collect-garbage -d
	# nixos generations
	sudo nix-env -p /nix/var/nix/profiles/system --list-generations
	sudo nix-collect-garbage -d
	sudo nix-env -p /nix/var/nix/profiles/system --list-generations
	# optimise store, soon nix.autoOptimise?
	nix-store --optimise

.PHONY: go
go: go ## Install go utils
	go install mvdan.cc/gofumpt@latest

.PHONY: update
update: ## Update packages
	nix flake update
	$(MAKE) switch

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



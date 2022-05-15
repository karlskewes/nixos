# NixOS Makefile

SHELL := /usr/bin/env bash -o errexit -o nounset -o pipefail -c

all: help

fmt: ## Format *.nix
	find . -name '*.nix' -print | \
		xargs -n 1 -- nixfmt

.PHONY: password
password: ## Create password hash
	# TODO: something better
	mkdir -p ~/src/nix-extra
	password='$(shell mkpasswd -m sha-512)' && \
					 echo "{ config, pkgs, ... }: { users.users.karl.hashedPassword = \"$${password}\"; }" > ~/src/nix-extra/nixos.nix
	sed -i 's@home/karl/src/nix-extra@home/nixos/src/nix-extra@' flake.nix

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

.PHONY: install
install: install ## Install NixOS for the first time
	sudo git config --global --add safe.directory /home/nixos/nixos
	sudo nixos-install --impure --root /mnt --flake .#

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
	go install -v mvdan.cc/gofumpt@latest
	go install -v golang.org/x/tools/cmd/godoc@latest

.PHONY: update
update: ## Update packages
	nix flake update
	$(MAKE) switch

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



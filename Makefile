# NixOS Makefile

SHELL := /usr/bin/env bash -o errexit -o nounset -o pipefail -c

all: help

fmt: ## Format *.nix
	find . -name '*.nix' -print | \
		xargs -n 1 -- nixfmt

.PHONY: nix-extra
nix-extra: ## Create nix-extra with any sensitive values
	mkdir -p ~/src/nix-extra
	password='$(shell mkpasswd -m sha-512)' && \
					 echo "{ config, pkgs, ... }:" \
					 "{ users.users.karl.hashedPassword = \"$${password}\"; }" \
					 > ~/src/nix-extra/nixos.nix

.PHONY: build
build: ## Build latest NixOS & home-manager configuration
	# update nix-extra reference if first time after install
	nix flake lock --update-input nix-extra
	# rebuild configuration per --flake .#${hostname}
	nixos-rebuild build --flake .#

.PHONY: build-rpi-sd-image
build-rpi-sd-image: ## Build RPi SD Image
	# update nix-extra reference if first time after install
	nix flake lock --update-input nix-extra
	# rebuild configuration per --flake .#${hostname}
	nixos-rebuild build --flake .#rpi1
	# build sdImage
	nix build .#nixosConfigurations.rpi1.config.system.build.sdImage
	ls -l ./result/sd-image/

.PHONY: diff
diff: build ## Build and diff
	nix-diff /run/current-system ./result

.PHONY: switch
switch: build ## Build latest and switch
	# Workaround CVE mitigation issue: https://github.com/NixOS/nixpkgs/pull/173170
	sudo git config --global --add safe.directory "$${PWD}"
	sudo nixos-rebuild switch --flake .#
	sudo ./result/activate
	sudo /run/current-system/bin/switch-to-configuration boot

.PHONY: install
install: nix-extra ## Install NixOS for the first time
	sed -i 's@home/karl/src/nix-extra@home/nixos/src/nix-extra@' flake.nix
	nix --extra-experimental-features "nix-command flakes" flake lock --update-input nix-extra
	sudo hostname "$$(read -p 'hostname: ' temp && echo $$temp)"
	nixos-rebuild build --flake .#$$(hostname)
	sudo nixos-install --impure --root /mnt --flake .#$$(hostname)

.PHONY: install-rpi-usb
install-rpi-usb: ## Install NixOS for RPi on USB HDD
	nixos-rebuild build --flake .#rpi1
	sudo nixos-install --impure --root /mnt/install/ --flake .#rpi1

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



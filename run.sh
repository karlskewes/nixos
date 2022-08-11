#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Simple task runner that's not Make so syntax highlighting and shellcheck, shfmt, etc work.
# https://gist.github.com/tvalladon/e316bee4b58ca082d2190be023565949

debug() { ## Debug REPL
	echo "Stopped in REPL. Press ^D to resume, or ^C to abort."
	local line
	while read -r -p "> " line; do
		eval "$line"
	done
	echo
}

fmt() { ## Format *.nix
	find . -name '*.nix' -print0 |
		xargs -n 1 -- nixfmt
}

nix-extra() { ## Create nix-extra with any sensitive values
	mkdir -p ~/src/nix-extra
	password=$(mkpasswd -m sha-512)
	cat <<EOF >~/src/nix-extra/nixos.nix
{ config, pkgs, ... }: {
  users.users.karl.hashedPassword = "${password}";
}
EOF
}

build() { ## Build latest NixOS & home-manager configuration
	# update nix-extra reference if first time after install
	nix flake lock --update-input nix-extra
	# rebuild configuration per --flake .#${hostname}
	nixos-rebuild build --flake .#
}

diff() { ## Build and diff
	build
	nix-diff /run/current-system ./result
}

switch() { ## Build latest and switch
	build
	# Workaround CVE mitigation issue: https://github.com/NixOS/nixpkgs/pull/173170
	sudo git config --global --add safe.directory "${PWD}"
	sudo nixos-rebuild switch --flake .#
	sudo ./result/activate
	sudo /run/current-system/bin/switch-to-configuration boot
}

install() { ## Install NixOS for the first time
	nix-extra
	sed -i 's@home/karl/src/nix-extra@home/nixos/src/nix-extra@' flake.nix
	nix --extra-experimental-features "nix-command flakes" flake lock --update-input nix-extra
	sudo hostname "$(read -rp 'hostname: ' temp && echo "$temp")"
	nixos-rebuild build --flake .#"$(hostname)"
	sudo nixos-install --impure --root /mnt/install/ --flake .#"$(hostname)"
}

clean() { ## Clean old generations
	# home manager
	nix-collect-garbage -d
	# nixos generations
	sudo nix-env -p /nix/var/nix/profiles/system --list-generations
	sudo nix-collect-garbage -d
	sudo nix-env -p /nix/var/nix/profiles/system --list-generations
	# optimise store, soon nix.autoOptimise?
	nix-store --optimise
}

goutils() { ## Install go utils
	go install -v mvdan.cc/gofumpt@latest
	go install -v golang.org/x/tools/cmd/godoc@latest
}

update() { ## Update packages
	nix flake update
	switch
}

one-arg-that-is-very-long() { ## Example that requires 1 arg <arg>
	if [ $# -ne 1 ]; then
		echo 1>&2 "Usage: $0 ${FUNCNAME[0]} <arg>"
		exit 3
	fi
	echo "Doing onearg thing with $1"
}

help() { ## Display usage for this application
	echo "$0 <task> <args>"
	grep -E '^[a-zA-Z_-]+\(\) { ## .*$' "$0" |
		sed -E 's/\(\)//' |
		sort |
		awk 'BEGIN {FS = "{.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $1, $2}'
}

TIMEFORMAT="Task completed in %3lR"
time "${@:-help}"

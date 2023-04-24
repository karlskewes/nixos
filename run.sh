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

## START NIX

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

	echo 'Tree-sitter may have parsers built for previous gcc version and require reinstalling parsers, consider:
  rm -rf ~/.local/share/lunarvim/site/pack/packer/start/nvim-treesitter/parser/*'

	clean
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
	# remove old entries from boot loader
	sudo /run/current-system/bin/switch-to-configuration boot
	# optimise store, soon nix.autoOptimise?
	nix-store --optimise
}

update() { ## Update packages
	nix flake update
	build
}

## END Nix

## START Extras

goutils() { ## Install go utils
	go install -v mvdan.cc/gofumpt@latest
	go install -v golang.org/x/tools/cmd/godoc@latest
	go install -v golang.org/x/perf/cmd/benchstat@latest
}

lvim() { ## Install lunarvim
	export LV_BRANCH="release-1.3/neovim-0.9"
	bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/release-1.3/neovim-0.9/utils/installer/install.sh)

	# grep this repo for comment convention: 'MasonInstall: <app1> <app2>'
	apps="$(grep ':MasonInstall' dotfiles/lvim/lua/user/languages/*.lua | cut -d ' ' -f 3- | xargs)"
	echo "lvim -c 'MasonInstall ${apps}'"
}

tree-sitter() {
	echo 'Tree-sitter may have parsers built for previous gcc version and require reinstalling parsers, removing...'
	rm ~/.local/share/lunarvim/site/pack/lazy/opt/nvim-treesitter/parser/*
}

mikrotik() { ## Backup Mikrotik router config
	ssh 192.168.1.1 export terse >../mikrotik_r1_backup_"$(date -Iseconds)".rsc
}

guestdisk() { ## Create a guest qcow2 file from base qcow2 file <input.img> <output.qcow2>
	if [ $# -ne 2 ]; then
		echo 1>&2 "Usage: $0 ${FUNCNAME[0]} <arg> <arg>"
		exit 3
	fi
	qemu-img create \
		-b "${1}" \
		-F qcow2 \
		-f qcow2 \
		"${2}"

	echo "Useful disk size commands:
  qemu-img info ubuntu-0.qcow2
  qemu-img resize ubuntu-0.qcow2 +18G
  "
}

# nix-shell -p cdrkit
userdata() { ## Generate NoCloud user-data cdrom image <directory>
	if [ $# -ne 1 ]; then
		echo 1>&2 "Usage: $0 ${FUNCNAME[0]} <arg>"
		exit 3
	fi
	genisoimage \
		-output "${1}"-cidata.iso \
		-V cidata \
		-r \
		-J "${1}"/meta-data "${1}"/user-data
}

## END Extras

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

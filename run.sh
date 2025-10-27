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

nix-extra() { ## Create nix-extra with any sensitive values
	mkdir -p ~/src/nix-extra
	password=$(mkpasswd -m sha-512)
	cat <<EOF >~/src/nix-extra/nixos.nix
{ config, pkgs, ... }: {
  users.users.karl.hashedPassword = "${password}";
}
EOF
}

nix-displaylink() { ## Setup DisplayLink driver in nix store
	local yyyymm="2024-10"
	local displaylink_version=610
	local ubuntu_version="6.1"

	# https://nixos.wiki/wiki/Displaylink
	# 6.0 - https://github.com/NixOS/nixpkgs/pull/317292
	curl -Lo "$HOME"/Downloads/displaylink-"${displaylink_version}".zip \
		https://www.synaptics.com/sites/default/files/exe_files/"${yyyymm}"/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu"${ubuntu_version}"-EXE.zip

	# TODO: confirm `--name` helps, or need to use `$PWD` in path like "Wiki".
	nix-prefetch-url \
		file://"$HOME"/Downloads/displaylink-"${displaylink_version}".zip

	nix-prefetch-url \
		--name displaylink-"${displaylink_version}".zip \
		file://"$HOME"/Downloads/displaylink-"${displaylink_version}".zip
}

# TODO: only needed during initial install
# --extra-experimental-features nix-command \
# --extra-experimental-features flakes \

build_darwin() {
	# Hack to supply real hostname, as friendly hostname "ABC-Macbook-Air" not found.
	nix run nix-darwin \
		-- build --impure --flake .#"${HOSTNAME%%.*}"
}

build_nixos() {
	# update nix-extra reference if first time after install
	nix flake update nix-extra
	# rebuild configuration per --flake .#${hostname}
	nixos-rebuild build --impure --flake .# --show-trace
}

build() { ## Build latest NixOS & home-manager configuration
	if [ "$(uname)" == "Darwin" ]; then
		echo "darwin detected, building..."
		build_darwin
	else
		echo "nixos detected, building..."
		build_nixos
	fi
}

diff() { ## Build and diff
	build
	nvd diff /nix/var/nix/profiles/system/ result/

	echo "see also: 'nvd list | grep asahi'"
	echo "see also: 'nix-diff /run/current-system ./result'"
}

switch_darwin() {
	# darwin-rebuild must now be run as root.
	sudo nix run nix-darwin \
		-- switch --impure --flake .#"${HOSTNAME%%.*}"
}

switch_linux() {
	# Workaround CVE mitigation issue: https://github.com/NixOS/nixpkgs/pull/173170
	sudo git config --global --add safe.directory "${PWD}"
	sudo nixos-rebuild switch --impure --flake .#
	sudo ./result/activate
	sudo /run/current-system/bin/switch-to-configuration boot

	# clean
}
switch() { ## Build latest and switch
	build

	if [ "$(uname)" == "Darwin" ]; then
		echo "darwin detected, switching..."
		switch_darwin
	else
		echo "nixos detected, switching..."
		switch_linux
	fi
}

install() { ## Install NixOS for the first time
	nix-extra
	sed -i 's@home/karl/src/nix-extra@home/nixos/src/nix-extra@' flake.nix
	nix --extra-experimental-features "nix-command flakes" flake update nix-extra
	if [[ $(hostname) == "nixos" ]]; then
		sudo hostname "$(read -rp 'hostname: ' temp && echo "$temp")"
	fi
	nixos-rebuild build --flake .#"$(hostname)"
	sudo nixos-install --impure --root /mnt/ --flake .#"$(hostname)"
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

	echo "check for stuck/old builds in /tmp/nixos-rebuild*"
	ls -l /tmp/nixos-rebuild*
}

update() { ## Update packages
	nix flake update
	build
}

pr() { ## Check PR landed on NixOS branch
	if [[ $# -ne 2 ]]; then
		pr="${1}"
	fi

	# Purely a bookmark.
	echo https://nixpkgs-tracker.ocfox.me/?pr="${pr:=451386}"
}

## END Nix

## START Extras

goutils() { ## Install go utils
	go install -v golang.org/x/tools/gopls@latest
	go install -v mvdan.cc/gofumpt@latest
	go install -v golang.org/x/tools/cmd/godoc@latest
	go install -v golang.org/x/perf/cmd/benchstat@latest
	go install -v honnef.co/go/tools/cmd/staticcheck@latest
	go install -v github.com/pressly/goose/v3/cmd/goose@latest # TODO here or elsewhere
}

fmt() { ## Format *.{lua,nix,sh}
	fd --extension nix | xargs nixfmt

	fd --extension lua | xargs stylua -g ./**/*.lua

	fd --extension sh | xargs shfmt -w
}

mikrotik() { ## Backup Mikrotik router config
	ssh 192.168.1.1 export terse >../mikrotik_r1_backup_"$(date -Iseconds)".rsc
}

tiny() { ## Tiny ZFS Unlock
	local host="192.168.1.5"
	ssh -v -p 2222 root@"${host}" "zpool import -a; zfs load-key -a && killall zfs"
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

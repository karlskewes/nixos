#!/usr/bin/env bash
# ZFS volume creation script, based on:
# - https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/2-system-configuration.html
# - https://nixos.wiki/wiki/ZFS

# Getting started on NixOS USB boot
# 1. set password for `nixos` user: `passwd`
# 2. scp ./zfs-vol.sh nixos@<IP>:.
# 3. edit and run

set -o errexit -o nounset -o pipefail

# Read disks into vim: `read !ls /dev/disk/by-id/*`
#ROOT_DISK='/dev/disk/by-id/ata-FOO'
ROOT_DISK=

#ROOT_PART=3
ROOT_PART=

#BOOT_PART=1
BOOT_PART=

#RPOOL should be unique across machines so can 'zfs import' without collisions.
#RPOOL=rpool-asus
RPOOL=

#DRYRUN flag '-n' can be specified to most/all? zfs commands
#DRYRUN=""  # disable dry run
DRYRUN="-n" # enable dry run

zpool_create() {
	sudo zpool create \
		"${DRYRUN}" \
		-o ashift=12 \
		-o autotrim=on \
		-R /mnt \
		-O canmount=off \
		-O mountpoint=none \
		-O acltype=posixacl \
		-O compression=zstd \
		-O dnodesize=auto \
		-O normalization=formD \
		-O relatime=on \
		-O xattr=sa \
		-O encryption=aes-256-gcm \
		-O keylocation=prompt \
		-O keyformat=passphrase \
		"${RPOOL}" \
		"${ROOT_DISK}-part${ROOT_PART}"
}

zfs_create() {

	zfs create \
		"${DRYRUN}" \
		-o refreservation=1G \
		-o mountpoint=none \
		"${RPOOL}/reserved"

	# create datasets that have snapshots ENABLED
	zfs create \
		"${DRYRUN}" \
		-o canmount=off \
		-o mountpoint=none \
		"${RPOOL}/snap"

	zfs set com.sun:auto-snapshot=true \
		"${DRYRUN}" \
		"${RPOOL}/snap"

	zfs create \
		"${DRYRUN}" \
		-o canmount=on \
		-o mountpoint=/ \
		"${RPOOL}/snap/root"

	# create datasets that have snapshots DISABLED
	zfs create \
		"${DRYRUN}" \
		-o canmount=off \
		-o mountpoint=none \
		"${RPOOL}/nosnap"

	zfs set com.sun:auto-snapshot=false \
		"${DRYRUN}" \
		"${RPOOL}/nosnap"

	# /nix volume can be recreated through download/update/etc
	zfs create \
		"${DRYRUN}" \
		-o canmount=on \
		-o mountpoint=/nix \
		"${RPOOL}/nosnap/nix"

	# swap doesn't persist reboots
	zfs create \
		"${DRYRUN}" \
		-V 4G -b "$(getconf PAGESIZE)" \
		-o compression=zle \
		-o logbias=throughput -o sync=always \
		-o primarycache=metadata -o secondarycache=none \
		"${RPOOL}/nosnap/swap"

	# docker manages its own snapshots and containers can be rebuilt
	zfs create \
		"${DRYRUN}" \
		-o canmount=on \
		-o mountpoint=/var/lib/docker \
		"${RPOOL}/nosnap/docker"
}

make_boot_dir() {
	if [[ "${DRYRUN}" == "-n" ]]; then
		return
	fi
	mkdir /mnt/boot
	mount "${ROOT_DISK}-part${BOOT_PART}" /mnt/boot
}

make_swap() {
	if [[ "${DRYRUN}" == "-n" ]]; then
		return
	fi
	mkswap -f "/dev/zvol/${RPOOL}/nosnap/swap"
	swapon -av
}

nixos_generate_config() {
	if [[ "${DRYRUN}" == "-n" ]]; then
		return
	fi
	nixos-generate-config --root /mnt
}

confirm() {
	echo "Continue with ${1}?"
	read -r response
	if [[ "$response" != "y" ]]; then
		exit 1
	fi
}

main() {
	echo "
Disks:"
	ls /dev/disk/by-id/*

	echo "
Settings:
ROOT_DISK=${ROOT_DISK}
ROOT_PART=${ROOT_PART}
RPOOL=${RPOOL}
  "

	confirm zpool_create
	# zpool_create
	confirm zfs_create
	# zfs_create
	confirm make_boot_dir
	# make_boot_dir
	confirm make_swap
	# make_swap
	confirm nixos_generate_config
	nixos_generate_config
}

main

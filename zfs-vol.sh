#!/usr/bin/env bash
# ZFS volume creation script, based on:
# - https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/2-system-configuration.html
# - https://nixos.wiki/wiki/ZFS

# Getting started on NixOS USB boot
# 1. set password for `nixos` user: `passwd`
# 2. scp ./zfs-vol.sh nixos@<IP>:.
# 3. edit and run

set -x -o errexit -o nounset -o pipefail

#RPOOL should be unique across machines so can 'zfs import' without collisions.
#RPOOL=rpool-asus
RPOOL=

# Read disks into vim: `read !ls /dev/disk/by-id/*`
#ROOT_DISK='/dev/disk/by-id/ata-FOO'
ROOT_DISK=

BOOT_PART=1
SWAP_PART=2
ROOT_PART=3

zpool_create() {
	sudo zpool create \
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
		-o refreservation=1G \
		-o mountpoint=none \
		"${RPOOL}/reserved"

	# create datasets that have snapshots ENABLED
	zfs create \
		-o canmount=off \
		-o mountpoint=none \
		"${RPOOL}/snap"

	zfs set com.sun:auto-snapshot=true \
		"${RPOOL}/snap"

	zfs create \
		-o canmount=on \
		-o mountpoint=legacy \
		"${RPOOL}/snap/root"

	# create datasets that have snapshots DISABLED
	zfs create \
		-o canmount=off \
		-o mountpoint=none \
		"${RPOOL}/nosnap"

	zfs set com.sun:auto-snapshot=false \
		"${RPOOL}/nosnap"

	# /nix volume can be recreated through download/update/etc
	zfs create \
		-o canmount=on \
		-o mountpoint=legacy \
		"${RPOOL}/nosnap/nix"

	# docker manages its own snapshots and containers can be rebuilt
	zfs create \
		-o canmount=on \
		-o mountpoint=legacy \
		"${RPOOL}/nosnap/docker"
}

make_boot_dir() {
	mkdir /mnt/boot
	mount "${ROOT_DISK}-part${BOOT_PART}" /mnt/boot
}

make_swap() {
	mkswap -L swap "${ROOT_DISK}-part${SWAP_PART}"
	swapon -av
}

mount_volumes() {
  mkdir -p /mnt
  zfs mount "${RPOOL}/snap/root" /mnt
  mkdir -p /mnt/nix
  zfs mount "${RPOOL}/nosnap/nix" /mnt/nix
  mkdir -p /mnt/var/lib/docker
  zfs mount "${RPOOL}/nosnap/docker" /mnt/var/lib/docker 
}

nixos_generate_config() {
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
RPOOL=${RPOOL}
ROOT_DISK=${ROOT_DISK}
BOOT_PART=${BOOT_PART}
SWAP_PART=${SWAP_PART}
ROOT_PART=${ROOT_PART}
  "

	confirm zpool_create
	zpool_create
	confirm zfs_create
	zfs_create
	confirm make_boot_dir
	make_boot_dir
	confirm make_swap
	make_swap
  confirm mount_volumes
  mount_volumes
	confirm nixos_generate_config
	nixos_generate_config
}

main

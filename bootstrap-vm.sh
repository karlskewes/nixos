#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

echo "bootstrapping NixOS - ready to go? y/n"
read -r ready
if [ "${ready}" != "y" ]; then
	echo "not ready, exiting..."
	exit 1
fi

echo "create partitions"
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 2 esp on

echo "format partitions"
mkfs.ext4 -L nixos /dev/sda1
mkfs.fat -F 32 -n boot /dev/sda2
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

echo "setup swapfile"
dd if=/dev/zero of=/mnt/swapfile bs=1MiB count=8000
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

echo "generate base config"
nixos-generate-config --root /mnt

echo "copy configs"
sudo cp ./nixos/* /mnt/etc/nixos

cd /mnt/etc/nixos
sed -i 's@swapDevices.*$@swapDevices = [ { device = "/swapfile"; size = 8000; } ];@' hardware-configuration.nix

# TODO nix-channel or tarball home-manager install?
echo "start nix-shell with git for home manager"
nix-shell -p git
sudo nixos-install

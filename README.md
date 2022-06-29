# NixOS

## TODO

1. LunarVim install derivation?
1. Linting/etc - https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#available-sources

## Update

```sh
git clone git@github.com:kskewes/nixos.git

# update packages from nix and then system & home-manager
make update
```

## New machine

### Prepare USB stick

- [x86](https://nixos.org/download.html)
- [aarch64](https://nixos.wiki/wiki/NixOS_on_ARM/UEFI)

```
nix-shell -p zstd --run "unzstd <img-name>.img.zst"
```

Burn to usb

```
lsblk

# dd bs=4M status=progress if=~/Downloads/nixos-minimal-22.05.538.d9794b04bff-x86_64-linux.iso of=
```

### Create partitions

Make sure to recreate swap partition or perform `zpool labelclear /dev/<swap|zpool-root>` to avoid `cannot import, more than 1 matching pool` error.

```
sudo fdisk /dev/sdX
```

- `n`, enter, `+1G` -> `t`, `1`, `uefi`
- `n`, enter, `+4G` -> `t`, `2`, `swap` - ZFS swap can deadlock under high memory pressure (COW)
- `n`, enter, enter -> `t`, `3`, `linux` - zfs all files
- `p`
- `w`

### Create `zfs` pool and datasets

[ZFS docs](https://nixos.wiki/wiki/ZFS#How_to_install_NixOS_on_a_ZFS_root_filesystem):

- `rpool-<machine>` - encrypted
- `rpool-<machine>/snap/root|other` - snapshots
- `rpool-<machine>/nosnap/nix|docker` - no snapshots

```
# create password for `nixos` user so can ssh to new machine
passwd

# from another computer scp volume script to nixos (or curl it from github)
scp ./zfs-vol.sh nixos@<new_machine>:.

# edit zfs volume script globals
vim ./zfs-vol.sh

# run
sudo ./zfs-vol.sh
```

### Install this flake

Add machine to this repository:

```
scp nixos@<new_machine>:/mnt/etc/nixos/hardware-configuration.nix machines/<name>.nix
vim flake.nix
git add .
...
```

Login and clone this repository on new machine:

```
nix-shell -p git

git clone https://github.com/kskewes/nixos.git
cd nixos

# increase tmpfs so we don't run out of space during nix build & install
sudo mount -o remount,size=10G /nix/.rw-store

# reduce imports so don't run out of space on low memory machines, for example
# drop: xwindows, dev, xserver
vim flake.nix

# build and install flake
make install

reboot
```

Login and install `home-manager`:

```
mkdir -p ~/src/github.com/kskewes
cd ~/src/github.com/kskewes

git clone https://github.com/kskewes/nixos.git

# create nix-extra again for `karl` instead of `nixos`
make nix-extra

make build

make switch
```

## Recovery

```
# find zfs pools
zpool import

# decrypt pool
zfs load-key -r rpool

# mount fs
mkdir -p /mnt/root
mount -t zfs rpool/root /mnt/root
```

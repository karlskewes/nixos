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

[Download ISO](https://nixos.org/download.html)

### Create partitions

Make sure to recreate swap partition or perform `zpool labelclear /dev/<swap|zpool-root>` to avoid `cannot import, more than 1 matching pool` error.

- 1GB EFI/ESP
- 4GB or so for swap because swap on ZFS can deadlock under high memory pressure
  (COW)
- possibly docker - maybe without snapshots it's ok?
- rest for files

```
parted
```

### Create `zfs` pool and datasets

[ZFS docs](https://nixos.wiki/wiki/ZFS#How_to_install_NixOS_on_a_ZFS_root_filesystem):

- rpool-<machine> - encrypted
- rpool-<machine>/snap/root|other - snapshots
- rpool-<machine>/nosnap/nix|docker - no snapshots

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
nix-shell -p gnumake git

git clone https://github.com/kskewes/nixos.git
cd nixos

# create nix-extra
make nix-extra

# set hostname for flake to match on (default nixos)
sudo hostname <machine>

# build and install flake without Home Manager (FIXME)
make install

reboot
```

Login and install `home-manager`:

```
mkdir -p ~/src/github.com/kskewes
cd ~/src/github.com/kskewes

git clone https://github.com/kskewes

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
zfs load-key -r rpool/

# mount fs
mount -t zfs rpool/root /mnt/root
```

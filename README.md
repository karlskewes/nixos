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

ZFS setup per [docs](https://nixos.wiki/wiki/ZFS#How_to_install_NixOS_on_a_ZFS_root_filesystem):

### Create partitions

- 1GB EFI/ESP
- 4GB or so for swap because swap on ZFS can deadlock under high memory pressure
  (COW)
- possibly docker - maybe without snapshots it's ok?
- rest for files

```
parted
```

### Create `zfs` pool and datasets

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

### Enable flakes

Add to `/etc/nixos/configuration.nix`:

```
  # Enable support for nix flakes - remove when `nix --version` >= 2.4
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Add appropriate machine here
  networking.hostId = "624e2a63";
  networking.hostName = "karl-laptop";
```

Install Flakes:

```
sudo nixos-rebuild switch
```

### Install this flake

Add machine to this repository:

```
scp nixos@<new_machine>:/mnt/etc/nixos/hardware-configuration.nix machines/<name>.nix
vim flake.nix
```

Login and clone this repository on new machine:

```
nix-shell -p gnumake git

git clone https://github.com/kskewes/nixos.git
```

Set user password:

```
make setup
```

final install:

```
make install
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

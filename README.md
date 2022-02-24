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

## New host

ZFS setup:

- https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/2-system-configuration.html
- https://nixos.wiki/wiki/ZFS#How_to_install_NixOS_on_a_ZFS_root_filesystem
- create separate swap partition not on zfs because reasons...
- consider separate docker partition not on zfs because reasons...
- rpool-<host/etc>/sys - encrypted base no mount
- rpool-<host/etc>/sys/root|nix - mount points, snapshots on root only

Enable flakes, add to `/etc/nixos/configuration.nix`

```
  # Enable support for nix flakes - remove when `nix --version` >= 2.4
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
```

then

```
sudo nixos-rebuild switch
```

Modify `flake.nix` with temporary location of `nix-extra` containing default
user and their password.

then:

```
make update
```

## Recovery

```
# find zfs pools
zpool import

# decrypt pool
zfs load-key -r rpool/sys/

# mount fs
mount -t zfs rpool/sys/root /mnt/root
```

# NixOS

## TODO

1. NixOS custom ISO for install per - https://bmcgee.ie/posts/2022/12/setting-up-my-new-laptop-nix-style/
1. LunarVim install derivation?
1. Linting/etc - https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#available-sources

## Update

```sh
git clone git@github.com:karlskewes/nixos.git

# update packages from nix and then system & home-manager
./run.sh update
```

## New machine

### Prepare USB stick

- [x86](https://nixos.org/download.html)

```
nix-shell -p zstd --run "unzstd <img-name>.img.zst"
```

Burn to USB

```
lsblk

# dd bs=4M status=progress if=~/Downloads/nixos-minimal-22.05.538.d9794b04bff-x86_64-linux.iso of=
```

Boot machine with nixos minimal image.

Create a password so we can SCP and SSH:

```
passwd
```

### Create Disko declarative partition file

Upstream: https://github.com/nix-community/disko

** CAUTION: This wipes away existing partitions **

```
machine=new_machine
cp ./hardware/karl-desktop-disko.nix ./hardware/"${machine}"-disko.nix

vim ./hardware/"${machine}"-disko.nix
```

Copy `disko` file to new machine:

```
host=
scp ./hardware/"${machine}"-disko.nix "${host}":.

```

ssh to host and configure partitions:

```
ssh nixos@"${host}"

machine=
nix \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes \
  run github:nix-community/disko --no-write-lock-file -- \
    --dry-run \
    --mode disko \
    ./"${machine}-disko.nix"
```

Then if ready do a run for real:

```
# as above without `--dry-run` flag
```

### Add machine to repository

Generate hardware:

```
nixos-generate-config --show-hardware-config
```

Copy into git repository:

```
vim ./hardware/${machine}.nix
```

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

git clone https://github.com/karlskewes/nixos.git
cd nixos

# increase tmpfs so we don't run out of space during nix build & install
sudo mount -o remount,size=10G /nix/.rw-store

# consider mounting swap if run out of memory during build
sudo swapon /dev/disk/by-id/<disk>-part2

# if still run out of memory, reduce imports, for example
# comment: xwindows, dev, xserver
vim flake.nix

# build and install flake
./run.sh install

reboot
```

Login and install `home-manager`:

```
mkdir -p ~/src/github.com/karlskewes
cd ~/src/github.com/karlskewes

git clone https://github.com/karlskewes/nixos.git

# create nix-extra again for `karl` instead of `nixos`
./run.sh nix-extra

./run.sh build

./run.sh switch
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

# NixOS

## TODO

1. NixOS custom ISO for install per - [https://bmcgee.ie/posts/2022/12/setting-up-my-new-laptop-nix-style/]
1. Linting/etc - [https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#available-sources]

## Update

```sh
git clone git@github.com:karlskewes/nixos.git

# update packages from nix and then system & home-manager
./run.sh update
```

## New machine

### Asahi Linux - btrfs

#### Prepare UEFI boot loader & Install base NixOS

Follow instructions at [https://github.com/nix-community/nixos-apple-silicon] with the
following variations.

Setup `disko.nix` partitions with luks encrypted `btrfs` because `zfs` support on new kernels is [spotty](https://github.com/nix-community/nixos-apple-silicon/issues/111):

### x86/arm64 - zfs

#### Prepare USB stick

- [x86](https://nixos.org/download.html)

```sh
nix-shell -p zstd --run "unzstd <img-name>.img.zst"
```

Burn to USB

```sh
lsblk

# dd bs=4M status=progress if=~/Downloads/nixos-minimal-22.05.538.d9794b04bff-x86_64-linux.iso of=
```

### Prepare machine branch

```sh
machine=new
git checkout -b "${machine}"
cp -a hosts/tl hosts/"${machine}"`

vim flake.nix
vim hosts/"${machine}"
```

### Create Disko declarative partition file

Upstream: https://github.com/nix-community/disko

```sh
nvim ./hosts/"${machine}"/disko.nix

git add ./hosts/"${machine}"/
git commit
git push
```

### Boot machine with NixOS minimal image

Create a password so we can SCP and SSH:

```sh
passwd
```

### Install over ssh

ssh to host and configure partitions:

```sh
ssh nixos@"${host}"

nix-shell -p git neovim

git clone https://github.com/karlskewes/nixos.git
cd nixos

# set machine to be setting up
machine=

git checkout "${machine}"

nix \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes \
  run github:nix-community/disko --no-write-lock-file -- \
    --mode format,mount \
    --dry-run \
    ./hosts/"${machine}/disko.nix"
```

Run for real (not dry run!):

```sh
# as above, but
# 1. `--mode destroy,format,mount` if clearing existing partitions
# 2. without `--dry-run`
# 3. `sudo`
# if zfs or luks encryption enabled, then expect prompt for passphrase.
sudo ...
```

#### Update machines hardware configuration

Generate hardware and copy output to repo config:

```sh
# sudo required when using luks encryption with btrfs otherwise will get:
# `Failed to retrieve subvolume info for /`
# note when re-partitioning, EFI, 'crypted' and other `/dev/disk/by-uuid/*` paths change.
sudo nixos-generate-config --root /mnt --show-hardware-config
sudo nixos-generate-config --root /mnt --show-hardware-config > ./hosts/"${machine}"/hardware-configuration.nix
```

Mount swap and remount nix-store with larger partition:

```sh
# increase tmpfs so we don't run out of space during nix build & install
# particularly when building a kernel for asahi.
sudo mount -o remount,size=14G /nix/.rw-store

# consider mounting swap if run out of memory during build
# zfs|ext4 swap partition
sudo mkswap /dev/disk/by-id/<disk>-part2
sudo swapon /dev/disk/by-id/<disk>-part2
# btrfs
sudo swapon --fixpgsz /mnt/swap/swapfile

sudo swapon -s

# if still run out of memory, reduce imports, for example
# comment: desktop, dev, wm
vim flake.nix

# copy asahi firmware if required:
sudo mkdir -p /mnt/etc/nixos/firmware
sudo cp /mnt/boot/asahi/* /mnt/etc/nixos/firmware

# build and install flake
# ensure that config.zfsBootUnlock.enable = false as host key doesn't yet exist
# for copying to initrd.
./run.sh install

reboot
```

Login and install `home-manager`:

```sh
mkdir -p ~/src/github.com/karlskewes
cd ~/src/github.com/karlskewes

git clone https://github.com/karlskewes/nixos.git

# create nix-extra again for `karl` instead of `nixos`
./run.sh nix-extra

./run.sh build

./run.sh switch
```

## Recovery

```sh
# find zfs pools
zpool import

# decrypt pool
zfs load-key -r rpool

# mount fs
mkdir -p /mnt/root
mount -t zfs rpool/root /mnt/root
```

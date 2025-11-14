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

### Darwin

Install nix from https://nixos.org/download/.

```sh
mkdir -p ~/src/github.com/karlskewes/
git clone https://github.com/karlskewes/nixos.git ~/src/github.com/karlskewes/nixos/
cd ~/src/github.com/karlskewes/nixos/

nix-shell -p mkpasswd
./run.sh nix-extra
./run.sh switch
```

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

disko.nix: `uuid = "<partuuid>";` per:

```sh
ls /dev/disk/by-partuuid/ -l
total 0
lrwxrwxrwx 1 root root 15 Jan  1  1970 0113ae75-de9c-4165-95db-f2c8a297c2d6 -> ../../nvme0n1p3
lrwxrwxrwx 1 root root 15 Jan  1  1970 68ec9ab1-1413-45bb-9553-e14aca305696 -> ../../nvme0n1p4
lrwxrwxrwx 1 root root 15 Jan  1  1970 ca58ee0f-d4de-4e27-a809-ac1c42d6fc24 -> ../../nvme0n1p1
lrwxrwxrwx 1 root root 15 Jan  1  1970 ec531500-04e8-4e3c-969d-f6f106b4e653 -> ../../nvme0n1p2
lrwxrwxrwx 1 root root 15 Jan  1  1970 fd9e528c-fe2d-49e9-afcd-c9cc9a0c65d2 -> ../../nvme0n1p5
```

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
# Specifically note the `crypted` LUKS uuid is for the partition `nvme0n1p6`, i.e: `061...`.
#
# [nix-shell:~/nixos]$ lsblk -f | grep crypt
# └─nvme0n1p6 crypto_LUKS 2                                    061de1ff-676d-4258-956e-ef67facb6de8
#   └─crypted btrfs                                            f49f6715-7b78-4f25-900d-9990388b750c  261.3G     3% /mnt/swap
#
sudo nixos-generate-config --root /mnt

# copy to repo via git or ssh
sudo nixos-generate-config --root /mnt --show-hardware-config
sudo nixos-generate-config --root /mnt --show-hardware-config > ./hosts/"${machine}"/hardware-configuration.nix
```

#### Apple Silicon only

```sh
sudo cp -a /etc/nixos/apple-silicon-support/ /mnt/etc/nixos/

# copy firmware
sudo mkdir -p /mnt/etc/nixos/firmware
sudo cp /mnt/boot/asahi/{all_firmware.tar.gz,kernelcache*} /mnt/etc/nixos/firmware

sudo nvim /mnt/etc/nixos/configuration.nix
# Add below:
cat<<EOF
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./apple-silicon-support
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false; # NOTE: toggled from default true
  boot.initrd.kernelModules = [ "cryptd" "dm-snapshot" ];
  boot.supportedFilesystems = [ "btrfs" ];

  # networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.enable = false;
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
EOF
```

#### Non-flake initial install

```sh
sudo nixos-install --root /mnt

reboot
```

#### Flake initial install

Move nix store from tmpfs to harddrive to avoid lack of space or inodes (`df -ih`):

```sh
sudo mkdir -p /mnt/install-nix-store/{upper,work}
sudo mkdir -p /mnt/install-nix-store-merged

sudo mount -t overlay overlay \
  -o lowerdir=/nix/store,upperdir=/mnt/install-nix-store/upper,workdir=/mnt/install-nix-store/work \
  /mnt/install-nix-store-merged

mount | grep overlay
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

# build and install flake
# ensure that config.zfsBootUnlock.enable = false as host key doesn't yet exist
# for copying to initrd.
./run.sh install

reboot
```

#### Install desktop and the rest

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

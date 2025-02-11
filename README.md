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

### Macbook M1

#### Prepare UEFI boot loader & Install base NixOS

Follow instructions at [https://github.com/tpwrules/nixos-apple-silicon] with the
following variations.

Setup partitions with ext4 because zfs support on new kernels is [spotty](https://github.com/tpwrules/nixos-apple-silicon/issues/111):

```sh
lsblk

fdisk /dev/nvme0n1

# confirm partition numbers before setting partition type
- `n`, enter, `+8G` -> `t`, `6`, `swap`
# TODO: change to BTRFS + LUKS + subvolumes for root, home, nix
- `n`, enter, `+100G` -> `t`, `7`, `linux` - `/` root, nix store
- `n`, enter, enter -> `t`, `8`, `linux` - `/home`
- `p`
- `w`
```

Mount partitions:

```sh
# print partition info
lsblk -o name,mountpoint,label,size,uuid

NAME        MOUNTP LABEL           SIZE UUID
nvme0n1                          931.5G
├─nvme0n1p1 /boot                  512M C0B8-20DA
├─nvme0n1p2 [SWAP] swap            7.5G b85bdf70-c212-4641-a96b-e2d0b9ad9f16
├─nvme0n1p3        rpool-desktop 492.7G 14791146668368940249
└─nvme0n1p7        data          329.4G 28385FE6385FB194

# root
mount /dev/disk/by-id/.... /mnt/

# home
mkdir -p /mnt/home
mount /dev/disk/by-id/.... /mnt/home

# swap
mkswap -L swap /dev/disk/by-id/....
swapon -av
```

Generate config:

```sh
nixos-generate-config --root /mnt/
```

Add to `/etc/nixos/configuration.nix`:

```
nix.settings.experimental-features = [ "nix-command" "flakes" ];

environment.systemPackages = with pkgs; [
  vim # edit files
  git # git clone this repo
];

# ensure iwd present for wifi

# consider adding ssh with password authentication
```

Install:

```sh
nixos-install --root /mnt/
```

#### Flake installation

- scp or git clone this repo
- set nix-extra username to root, or mkdir /home/nixos
- increase tmpfs storage for /run/user/0 to 10G (less ok?)

### x86/arm64

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

Boot machine with NixOS minimal image.

Create a password so we can SCP and SSH:

```sh
passwd
```

### Create Disko declarative partition file

Upstream: https://github.com/nix-community/disko

** CAUTION: This wipes away existing partitions **

```sh
machine=new_machine
cp ./hardware/tl-disko.nix ./hardware/"${machine}"-disko.nix

vim ./hardware/"${machine}"-disko.nix
```

Copy `disko` file to new machine:

```sh
host=
scp ./hardware/"${machine}"-disko.nix "${host}":.

```

ssh to host and configure partitions:

```sh
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

```sh
# as above without `--dry-run` flag
```

#### Add machine to repository

Generate hardware:

```sh
nixos-generate-config --show-hardware-config
```

Copy into git repository:

```sh
vim ./hardware/${machine}.nix
```

Add machine to this repository:

```sh
scp nixos@<new_machine>:/mnt/etc/nixos/hardware-configuration.nix machines/<name>.nix
vim flake.nix
git add .
...
```

Login and clone this repository on new machine:

```sh
nix-shell -p git

git clone https://github.com/karlskewes/nixos.git
cd nixos

# increase tmpfs so we don't run out of space during nix build & install
sudo mount -o remount,size=10G /nix/.rw-store

# consider mounting swap if run out of memory during build
sudo swapon /dev/disk/by-id/<disk>-part2

# if still run out of memory, reduce imports, for example
# comment: desktop, dev, xserver
vim flake.nix

# build and install flake
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

#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# likely to go out of date
echo "installing nixos-unstable channel for neovim"
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update

echo "installing home-manager"
nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager
nix-channel --update
nix-shell -p home-manager

echo "configuring user"
home-manager switch -f home-manager/base.nix

echo "ready to logout/login MOD+SHIFT+E"

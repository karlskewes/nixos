#!/bin/bash

set -o errexit -o nounset -o pipefail

# likely to go out of date

echo "installing home-manager"
nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz home-manager
nix-channel --update
nix-shell -p home-manager

echo "configuring user"
home-manager switch -f home-manager/base.nix

echo "update i3"
sed -i 's/i3-sensible-terminal/alacritty/' ~/.config/i3/config

echo "ready to logout/login MOD+SHIFT+E"

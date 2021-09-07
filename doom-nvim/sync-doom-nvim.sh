#!/bin/bash

set -o errexit -o nounset -o pipefail

echo "fetch doom-nvim"
git clone --depth 1 https://github.com/NTBBloodbath/doom-nvim.git ${XDG_CONFIG_HOME:-$HOME/.config}/nvim

cp doom* ~/.config/nvim/

echo "ready to run doom-nvim"

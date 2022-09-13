{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bats
    delve
    go-jsonnet
    golangci-lint
    gotools
    jsonnet-bundler
    lua
    luaformatter
    nodePackages.prettier
    nodePackages.write-good
    openssl
    rnix-lsp
    shellcheck
    shfmt
    stylua
    sumneko-lua-language-server

    cargo
    rustc

    nodejs # neovim

    python39 # neovim # https://docs.python.org/3/
    python39Packages.flake8
    python39Packages.pip
    python39Packages.pynvim # lunarvim
    pylint
    black

    # clouds
    # awscli2

    # kubernetes
    kubectl
    kubectx
    kubeval
  ];

  programs.go = {
    enable = true;
    package = pkgs.go_1_19;
  };
}

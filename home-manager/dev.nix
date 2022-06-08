{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # dev
    bats
    # delve # no aarch64-linux
    go-jsonnet
    golangci-lint
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

    # clouds
    # awscli2
    nodejs # neovim

    python39 # neovim # https://docs.python.org/3/
    python39Packages.flake8
    pylint
    black

    # kubernetes
    kubectl
    kubectx
    kubeval
  ];

  programs.go = {
    enable = true;
    package = pkgs.go_1_17;
  };
}

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    bats
    shellcheck
    shfmt

    buf
    delve
    golangci-lint
    gopls
    glibc
    gotools
    graphviz # go tool pprof -http localhost:8080 ./profile.out

    hugo
    wails # wails.io

    go-jsonnet
    jsonnet-bundler

    lua
    luaformatter
    stylua
    sumneko-lua-language-server

    nodePackages.prettier
    nodePackages.write-good

    openssl

    rnix-lsp

    cargo
    rustc

    nodejs # neovim
    nodePackages_latest.wrangler # Cloudflare

    python310 # neovim # https://docs.python.org/3/
    python310Packages.flake8
    python310Packages.pip
    python310Packages.pynvim # lunarvim
    python310Packages.debugpy # lunarvim DAP
    python310Packages.pytest # lunarvim DAP
    pylint
    black

    # clouds
    awscli2
    aws-vault
    # google-cloud-sdk # gsutil, etc
    docker-compose
    pulumi-bin

    # kubernetes
    kubectl
    kubectx
    kubeval
  ];

  programs.go = {
    enable = true;
    package = pkgs.go_1_21;
    # export GOPRIVATE=github.com/karlskewes/*
    goPrivate = [ "github.com/karlskewes/*" ];
  };
}

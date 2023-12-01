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
    rust-analyzer
    rustfmt

    nodejs # neovim
    # nodePackages_latest.wrangler # Cloudflare # FIXME, broken, nixpkgs issue

    python311 # neovim # https://docs.python.org/3/
    python311Packages.flake8
    python311Packages.pip
    python311Packages.pynvim # lunarvim
    python311Packages.debugpy # lunarvim DAP
    python311Packages.pytest # lunarvim DAP
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

{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    bats
    shellcheck
    shfmt

    air # hot reload Go apps
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

    kazam # screencasting

    lua
    luaformatter
    luarocks
    stylua
    sumneko-lua-language-server

    nodePackages.prettier
    nodePackages.write-good

    openssl

    cargo
    rustc
    rust-analyzer
    rustfmt

    nodejs # neovim
    # nodePackages_latest.wrangler # Cloudflare # FIXME, broken, nixpkgs issue

    python311 # neovim # https://docs.python.org/3/
    python311Packages.flake8
    python311Packages.pip
    python311Packages.pynvim
    python311Packages.debugpy
    python311Packages.pytest
    pylint
    black

    # DO: npm install -D tailwindcss postcss-cli @fullhuman/postcss-purgecss
    # RUN: npx {tailwindcss, postcss, etc} --help
    # WARNING: Below packages need to be in node_modules dir, not nix store.
    # tailwindcss
    # nodePackages.autoprefixer
    # nodePackages.postcss-cli

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
    package = lib.mkDefault pkgs.go_1_22;
    # export GOPRIVATE=github.com/karlskewes/*
    goPrivate = [ "github.com/karlskewes/*" ];
  };
}

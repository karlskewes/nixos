{ config, lib, pkgs, isDarwin, isLinux, ... }:

{
  home.packages = with pkgs;
    (lib.optionals isDarwin [ ]) ++ (lib.optionals isLinux [
      glibc # golangci-lint ?
      vokoscreen-ng # screencasting
    ]) ++ [
      bats
      shellcheck
      shfmt

      air # hot reload Go apps
      buf
      delve
      gofumpt
      golangci-lint
      gotools
      templ
      graphviz # go tool pprof -http localhost:8080 ./profile.out

      hugo

      go-jsonnet
      jsonnet-bundler

      lua
      luarocks
      stylua

      nodePackages.write-good
      nodejs_22 # neovim # nodejs_24 constantly builds
      # nodePackages_latest.wrangler # Cloudflare # FIXME, broken, nixpkgs issue

      openssl

      cargo
      cargo-audit
      cargo-watch
      clang
      clippy
      pkg-config
      openssl
      rustc
      rustfmt
      (lib.hiPrio gcc)

      sql-formatter

      zig

      python312 # neovim # https://docs.python.org/3/
      python312Packages.black
      python312Packages.flake8
      python312Packages.isort
      python312Packages.pylint
      python312Packages.pip
      python312Packages.pynvim
      python312Packages.debugpy
      python312Packages.pytest

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
      terraform

      # kubernetes
      kubectl
      kubectx
      kubeval
    ];

  programs.go = {
    enable = true;
    package = lib.mkDefault pkgs.go_1_24;
    # export GOPRIVATE=github.com/karlskewes/*
    goPrivate = [ "github.com/karlskewes/*" ];
  };
}

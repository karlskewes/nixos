{ lib, pkgs, isDarwin, isLinux, ... }:

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

      cargo-audit
      cargo-watch
      clang
      pkg-config
      openssl
      # managed by rustup in ~/.rustup/
      # cargo
      # clippy
      # rustc
      # rustfmt
      rustup
      (lib.hiPrio gcc)

      sql-formatter
      sqlitebrowser

      zig

      python313 # neovim # https://docs.python.org/3/
      python313Packages.black
      python313Packages.flake8
      python313Packages.isort
      python313Packages.pylint
      python313Packages.pip
      python313Packages.pynvim
      python313Packages.debugpy
      python313Packages.pytest
      python313Packages.uv # package manager

      # DO: npm install -D tailwindcss postcss-cli @fullhuman/postcss-purgecss
      # RUN: npx {tailwindcss, postcss, etc} --help
      # WARNING: Below packages need to be in node_modules dir, not nix store.
      # tailwindcss
      # nodePackages.autoprefixer
      # nodePackages.postcss-cli

      # clouds
      awscli2
      aws-vault # TODO: convert nixpkgs to maintained fork.
      # azure?
      # google-cloud-sdk # gsutil, etc
      flyctl # fly.io
      docker-compose
      pulumi-bin
      opentofu
      terraform

      # kubernetes
      kubectl
      kubectx
      kubeval
    ];

  programs.bash.shellAliases = {
    docker = lib.mkIf (isDarwin) "podman";
    dco = "docker-compose";
    k = "kubectl";
    # podman docker host export
    # https://podman-desktop.io/docs/migrating-from-docker/using-the-docker_host-environment-variable
    pdh =
      "export DOCKER_HOST=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')";
  };

  programs.bash.initExtra = ''
    source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
    complete -F __start_kubectl k
  '';

  programs.go = {
    enable = true;
    package = lib.mkDefault pkgs.go_1_25;
    # export GOPRIVATE=github.com/karlskewes/*
    env.GOPRIVATE = [ "github.com/karlskewes/*" ];
  };
}

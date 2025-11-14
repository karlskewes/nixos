{ lib, pkgs, isDarwin, isLinux, ... }:

{
  home.packages = with pkgs;
    (lib.optionals isDarwin [ ]) ++ (lib.optionals isLinux [
      glibc # golangci-lint ?
      vokoscreen-ng # screencasting

      # ssh key related
      gcr_4
      seahorse
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
      gdb
      lldb_19 # lldb_21 not supported - crashes.
      # https://github.com/mrcjkb/rustaceanvim?tab=readme-ov-file#using-codelldb-for-debugging
      # vscode-extensions.vadimcn.vscode-lldb # `codelldb` not found in path, TODO

      # https://nixos.wiki/wiki/FAQ/I_installed_a_library_but_my_compiler_is_not_finding_it._Why%3F
      # `nix-shell -p pkg-config openssl`
      # pkg-config
      # openssl

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

  # On Darwin, use of `docker` in scripts will fail to match an alias or function named docker.
  # Perhaps worth moving from Podman to Colima or the new Apple native docker containerization?
  home.file.".local/bin/docker" =
    lib.mkIf isDarwin { source = ../../dotfiles/docker; };

  programs.bash.shellAliases = {
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

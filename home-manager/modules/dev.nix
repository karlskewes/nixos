{
  lib,
  pkgs,
  isDarwin,
  isLinux,
  ...
}:

let
  maudfmt = pkgs.rustPlatform.buildRustPackage {
    pname = "maudfmt";
    version = "0.1.9";
    doCheck = false; # bypass tests that fail due to different source tree layout.
    src = pkgs.fetchFromGitHub {
      owner = "jeosas";
      repo = "maudfmt";
      rev = "d72b822023dad4d70e2a78e2345ee326050f6e47";
      hash = "sha256-uDpVczivGCHafJ8k4vT+rgXvFRws5UcJlKq2WXHXHzU=";
    };
    cargoHash = "sha256-k7ZZQBsa72jlHSunFrg8wQsmJ/ICJK94/NVK9DQr12A=";
  };
in
{
  home.packages =
    with pkgs;
    (lib.optionals isDarwin [ ])
    ++ (lib.optionals isLinux [
      glibc # golangci-lint ?
      vokoscreen-ng # screencasting

      # ssh key related
      gcr_4
      seahorse
    ])
    ++ [
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

      write-good
      nodejs_22 # neovim # nodejs_24 constantly builds
      # wrangler # Cloudflare # FIXME, broken, nixpkgs issue

      maudfmt
      sccache # Mozilla's shared compilation cache. ~/.cache/sccache
      bacon # replace cargo-watch
      cargo-audit
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
      # rustfmt # rustup component add rustfmt
      # rust-analyzer # rustup component add rust-analyzer
      rustup
      (lib.hiPrio gcc)

      sql-formatter
      sqlitebrowser

      zig

      python314 # neovim # https://docs.python.org/3/
      python314Packages.black
      python314Packages.flake8
      python314Packages.isort
      python314Packages.pylint
      python314Packages.pip
      python314Packages.pynvim
      python314Packages.debugpy
      python314Packages.pytest
      python314Packages.uv # package manager

      # DO: npm install -D tailwindcss postcss-cli @fullhuman/postcss-purgecss
      # RUN: npx {tailwindcss, postcss, etc} --help
      # WARNING: Below packages need to be in node_modules dir, not nix store.
      # tailwindcss
      # autoprefixer
      # postcss-cli

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
  home.file.".local/bin/docker" = lib.mkIf isDarwin { source = ../../dotfiles/docker; };

  programs.bash.shellAliases = {
    dco = "docker-compose";
    k = "kubectl";
    # podman docker host export
    # https://podman-desktop.io/docs/migrating-from-docker/using-the-docker_host-environment-variable
    pdh = "export DOCKER_HOST=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')";
  };

  programs.bash.initExtra = ''
    source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
    complete -F __start_kubectl k
  '';

  programs.go = {
    enable = true;
    package = lib.mkDefault pkgs.go_1_26;
    # export GOPRIVATE=github.com/karlskewes/*
    env.GOPRIVATE = [ "github.com/karlskewes/*" ];
  };

  # Tell rust to use sccache, default 10GB to ~/.cache/sccache
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';
}

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # dev
    bats
    delve
    go-jsonnet
    golangci-lint
    jsonnet-bundler
    lua
    luaformatter
    openssl
    rnix-lsp
    shellcheck
    shfmt
    stylua
    sumneko-lua-language-server

    # web
    hugo

    # clouds
    awscli2
    nodejs # neovim
    pulumi-bin
    terraform

    # kubernetes
    kind
    kubectl
    kubectx
    kubeval
    stern
  ];

  programs.go = {
    enable = true;
    package = pkgs.go_1_17;
  };
}

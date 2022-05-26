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

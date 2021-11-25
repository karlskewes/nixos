{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # dev
    bats
    go-jsonnet
    golangci-lint
    jsonnet-bundler
    openssl
    rnix-lsp
    shellcheck
    shfmt

    # clouds
    awscli2
    nodejs # cdktf and neovim
    nodePackages.cdktf-cli
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

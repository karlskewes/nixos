{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # dev
    bats
    go-jsonnet
    unstable.golangci-lint
    jsonnet-bundler
    openssl
    rnix-lsp
    shellcheck
    shfmt

    # clouds
    awscli2
    nodejs # cdktf and neovim
    unstable.nodePackages.cdktf-cli
    unstable.terraform

    # kubernetes
    kind
    kubectl
    kubectx
    kubeval
    stern
  ];

  programs.go = { enable = true; };

}

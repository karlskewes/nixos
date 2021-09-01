{ config, pkgs, ... }:

# laptop not server

{
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    # dev
    go-jsonnet
    jsonnet-bundler
    openssl
    shellcheck
    shfmt
    terraform  # terraform_0_12
    
    # kubernetes
    kind
    kubectl
    kubectx
    stern
  ];

  programs.go = {
    enable = true;
  };

}

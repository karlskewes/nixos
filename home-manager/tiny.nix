(
  { config, pkgs, ... }:
  {
    imports = [
      ./user-karl.nix

      ./modules

      ./modules/dev.nix
    ];

    home.packages = with pkgs; [ tmux ];
  }
)

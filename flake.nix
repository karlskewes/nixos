{
  description = "NixOS Flake";

  inputs = {
    # use unstable by default for freshest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # tell home-manager to use same packages as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:mjlbach/neovim-nightly-overlay";

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;
  };

  outputs = { self, home-manager, nixpkgs, nix-extra, ... }@inputs:
    let
      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = [ inputs.neovim-nightly-overlay.overlay ];

      # Function to render out our hosts
      mkHost = import ./lib/mkHost.nix;

      # Let 'nixos-version --json' know about the Git revision
      configRev = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;

      user = "karl";
      emailAddress = "karl.skewes@gmail.com";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew karl.skewes@gmail.com"
      ];
      importsCommon = [
        ./home-manager/base.nix
        ./home-manager/dev.nix
        ./home-manager/xwindows.nix
      ];
      extraModules = [
        "${nix-extra.outPath}/nixos.nix"
        ./system/base.nix
        ./system/xserver.nix
      ];

    in {
      nixosConfigurations = {
        karl-desktop = mkHost "karl-desktop" rec {
          inherit nixpkgs home-manager nix-extra overlays configRev user
            emailAddress extraModules authorizedKeys;
          system = "x86_64-linux";
          homeConfig = ({ config, pkgs, ... }: {
            imports = importsCommon;
            home.packages = with pkgs; [
              delve
              discord
              google-chrome
              kind
              slack
            ];
            xresources.properties = { "Xft.dpi" = "109"; };
          });
        };

        karl-laptop = mkHost "karl-laptop" rec {
          inherit nixpkgs home-manager nix-extra overlays configRev user
            emailAddress extraModules authorizedKeys;
          system = "x86_64-linux";
          homeConfig = ({ config, pkgs, ... }: {
            imports = importsCommon;
            home.packages = with pkgs; [ delve discord google-chrome slack ];
            xresources.properties = { "Xft.dpi" = "96"; };
          });
        };

        rpi = mkHost "rpi" rec {
          inherit nixpkgs home-manager nix-extra overlays configRev user
            emailAddress extraModules authorizedKeys;
          system = "aarch64-linux";
          homeConfig = ({ config, pkgs, ... }: {
            imports = importsCommon;
            xresources.properties = { "Xft.dpi" = "64"; };
          });
        };
      };
    };
}

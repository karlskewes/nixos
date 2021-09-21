{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      # tell home-manager to use same packages as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:mjlbach/neovim-nightly-overlay";
  };

  # pass all inputs to outputs
  outputs = { self, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import inputs.nixpkgs {
        inherit system;
        # required for chrome, perhaps could move elsewhere per machine/group
        config = { allowUnfree = true; };
      };

      lib = inputs.nixpkgs.lib;

    in {
      homeManagerConfigurations = {

        # TODO - dedupe these
        karl-laptop = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs;
          username = "karl";
          homeDirectory = "/home/karl";
          stateVersion = "21.05"; # HACK for version mismatch error
          configuration = { config, pkgs, ... }:
            let
              nixos-unstable-overlay = final: prev: {
                unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
              };
              overlays = [
                nixos-unstable-overlay
                inputs.neovim-nightly-overlay.overlay
              ];
            in {
              nixpkgs.overlays = overlays;
              imports = [
                ./home-manager/base.nix
                ./home-manager/dev.nix
                ./home-manager/xwindows.nix
              ];
              home.packages = with pkgs; [ discord slack ];
              programs.git = { userEmail = "karl.skewes@gmail.com"; };
              xresources.properties = { "Xft.dpi" = "109"; };
            };
        };

        karl-desktop = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs;
          username = "karl";
          homeDirectory = "/home/karl";
          stateVersion = "21.05"; # HACK for version mismatch error
          configuration = { config, pkgs, ... }:
            let
              nixos-unstable-overlay = final: prev: {
                unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
              };
              overlays = [
                nixos-unstable-overlay
                inputs.neovim-nightly-overlay.overlay
              ];
            in {
              nixpkgs.overlays = overlays;
              imports = [
                ./home-manager/base.nix
                ./home-manager/dev.nix
                ./home-manager/xwindows.nix
              ];
              home.packages = with pkgs; [ discord slack ];
              programs.git = { userEmail = "karl.skewes@gmail.com"; };
              xresources.properties = { "Xft.dpi" = "109"; };
            };
        };
      };

      nixosConfigurations = {
        karl-desktop = lib.nixosSystem {
          inherit system;
          modules = [ ./machines/karl-desktop.nix ];
        };

        karl-laptop = lib.nixosSystem {
          inherit system;
          modules = [ ./machines/karl-laptop.nix ];
        };

        karl-mac-vmware = lib.nixosSystem {
          inherit system;
          modules = [ ./machines/karl-mac-vmware.nix ];
        };
      };

    };
}

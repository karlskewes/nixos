{
  description = "NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      # tell home-manager to use same packages as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        # required for chrome, perhaps could move elsewhere per machine/group
        config = { allowUnfree = true; };
      };

      lib = nixpkgs.lib;

    in {
      # TODO:
      # homeManagerConfigurations = {
      # karl = home-manager.lib.homeManagerConfiguration {
      # inherit system pkgs;
      # username = "karl";
      # homeDirectory = "/home/karl";
      # configuration = {
      # imports = [

      # ];
      # };
      # };
      # };

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

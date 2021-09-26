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

      # shared between home-manager and nixos
      system = "x86_64-linux";

      # Home Manager
      username = "karl";
      homeDirectory = "/home/karl";
      stateVersion = "21.05"; # HACK for version mismatch error

      importsCommon = [
        ./home-manager/base.nix
        ./home-manager/dev.nix
        ./home-manager/xwindows.nix
      ];

      pkgs = import inputs.nixpkgs {
        inherit system;
        # required for chrome, perhaps could move elsewhere per machine/group
        config = { allowUnfree = true; };
      };

      lib = inputs.nixpkgs.lib;
      nixos-unstable-overlay = final: prev: {
        unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
      };
      overlaysCommon =
        [ nixos-unstable-overlay inputs.neovim-nightly-overlay.overlay ];

      # NixOS
      modulesCommon = [ ./machines/base.nix ./machines/xserver.nix ];

    in {
      homeManagerConfigurations = {
        karl-laptop = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs username homeDirectory stateVersion;
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = overlaysCommon;
            imports = importsCommon;
            home.packages = with pkgs; [ discord slack ];
            programs.git = { userEmail = "karl.skewes@gmail.com"; };
            xresources.properties = { "Xft.dpi" = "109"; };
          };
        };

        karl-desktop = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs username homeDirectory stateVersion;
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = overlaysCommon;
            imports = importsCommon;
            home.packages = with pkgs; [ discord slack ];
            programs.git = { userEmail = "karl.skewes@gmail.com"; };
            xresources.properties = { "Xft.dpi" = "109"; };
          };
        };

        karl-mac-vmware = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs username homeDirectory stateVersion;
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = overlaysCommon;
            imports = importsCommon ++ [ ./home-manager/karl-mac-vmware.nix ];
          };
        };
      };

      nixosConfigurations = {
        karl-desktop = lib.nixosSystem {
          inherit system;
          modules = modulesCommon ++ [
            ./machines/hardware-configuration-karl-desktop.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "f299660e";
              networking.hostName = "karl-desktop";
              boot.supportedFilesystems = [ "zfs" ];
              networking.interfaces.enp8s0.useDHCP = true;
            })
          ];
        };

        karl-laptop = lib.nixosSystem {
          inherit system;
          modules = modulesCommon ++ [
            ./machines/hardware-configuration-karl-desktop.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "ff8fd5cb";
              networking.hostName = "karl-laptop";
              boot.supportedFilesystems = [ "zfs" ];
              networking.interfaces.ens33.useDHCP = true;
            })
          ];
        };

        karl-mac-vmware = lib.nixosSystem {
          inherit system;
          modules = modulesCommon ++ [
            ./machines/hardware-configuration-karl-mac-vmware.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;
              networking.hostName = "karl-mac-vmware";
              environment.systemPackages = with pkgs;
              # This is needed for the vmware user tools clipboard to work.
              # You can test if you don't need this by deleting this and seeing
              # if the clipboard still works.
                [ gtkmm3 ];
              hardware.video.hidpi.enable = true;
              services.xserver.dpi = 220;
              virtualisation.vmware.guest.enable = true;
            })
          ];
        };
      };

    };
}

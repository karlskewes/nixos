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

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # Pin to a nixpkgs revision that doesn't have NixOS/nixpkgs#208103 yet
      # inputs.nixpkgs.url =
      # "github:nixos/nixpkgs?rev=fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
    };

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;
  };

  outputs =
    { self
    , home-manager
    , nixpkgs
    , apple-silicon-support
    , nix-extra
    , ...
    }@inputs:
    let
      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = [ inputs.neovim-nightly-overlay.overlay ];
      # overlays = [ ];

      # Function to render out our hosts
      mkHost = import ./lib/mkHost.nix;

      # Let 'nixos-version --json' know about the Git revision
      configRev = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;

      user = "karl";
      stateVersion = "22.05";
      hmModules = [
        ./home-manager/dev.nix
        ./home-manager/xwindows.nix
      ];
      hmShared = [
        ./home-manager/shared.nix
      ];
      nixosModules = [
        "${nix-extra.outPath}/nixos.nix"
        ./system/base.nix
        ./system/xserver.nix
      ];

      appleOverlays = [ apple-silicon-support.overlays.default ];

    in
    {
      nixosConfigurations = {
        karl-desktop = mkHost "karl-desktop" rec {
          inherit nixpkgs home-manager nix-extra overlays configRev user
            stateVersion;
          system = "x86_64-linux";
          extraModules = nixosModules
            ++ [ ./system/libvirtd.nix ./system/zfs.nix ];
          homeConfig = ({ config, pkgs, ... }: {
            imports = hmModules ++ [
              ./home-manager/user-${user}.nix
            ];
            home.packages = with pkgs; [ discord kind restic slack zoom-us ];
            xresources.properties = { "Xft.dpi" = "109"; };
          });
          homeShared = hmShared;
        };

        blake-laptop = mkHost
          "blake-laptop"
          rec {
            inherit nixpkgs home-manager nix-extra overlays configRev user
              stateVersion;
            system = "x86_64-linux";
            extraModules = nixosModules ++ [ ./system/zfs.nix ];
            homeConfig = ({ config, pkgs, ... }: {
              imports = hmModules;
              home.packages = with pkgs; [ ];
              xresources.properties = { "Xft.dpi" = "96"; };
            });
            homeShared = hmShared;
          };

        karl-mba = mkHost
          "karl-mba"
          rec {
            inherit nixpkgs home-manager nix-extra configRev user
              ;
            system = "aarch64-linux";
            overlays = [ apple-silicon-support.overlays.default ];
            stateVersion = "23.11";
            extraModules = nixosModules;
            homeConfig = ({ config, pkgs, ... }: {
              imports = hmModules ++ [
                ./home-manager/user-${user}.nix
              ];
              # TODO, unsupported
              # home.packages = with pkgs; [ discord slack ];
              home.pointerCursor.size = 180; # 4k
              xresources.properties = { "Xft.dpi" = "220"; };
            });
            homeShared = hmShared;
          };

        shub = mkHost
          "shub"
          rec {
            inherit nixpkgs home-manager nix-extra overlays configRev user
              stateVersion;
            system = "x86_64-linux";
            extraModules = nixosModules ++ [ ./system/zfs.nix ];
            homeConfig = ({ config, pkgs, ... }: {
              imports = hmModules ++ [
                ./home-manager/user-${user}.nix
              ];
              home.packages = with pkgs; [ tmux ];
            });
            homeShared = hmShared;
          };

        tl = mkHost
          "tl"
          rec {
            inherit nixpkgs home-manager nix-extra overlays configRev user
              stateVersion;
            system = "x86_64-linux";
            extraModules = nixosModules ++ [ ./system/zfs.nix ];
            homeConfig = ({ config, pkgs, ... }: {
              imports = hmModules ++ [
                ./home-manager/user-${user}.nix
              ];
              # home.pointerCursor.size = 180; # 4k
              xresources.properties = { "Xft.dpi" = "109"; }; # 180 on 4k
            });
            homeShared = hmShared;
          };

      };
    };
}

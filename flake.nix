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

      # Function to render out our hosts
      mkHost = import ./lib/mkHost.nix;

      # Let 'nixos-version --json' know about the Git revision
      configRev = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;

      user = "karl";
      extraModules = [ "${nix-extra.outPath}/nixos.nix" ];
      appleModules = extraModules ++ [ apple-silicon-support.nixosModules.default ];

    in
    {
      nixosConfigurations = {
        blake-laptop = mkHost "blake-laptop" rec {
          inherit nixpkgs home-manager overlays extraModules configRev user;
          system = "x86_64-linux";
          stateVersion = "22.05";
          homeModule = ({ config, pkgs, ... }: {
            # TODO: multiple users
            imports = [ ./home-manager/user-${user}.nix ];
            home.packages = with pkgs; [ ];
            xresources.properties = { "Xft.dpi" = "96"; };
          });
        };

        karl-desktop = mkHost "karl-desktop" rec {
          inherit nixpkgs home-manager overlays extraModules configRev user;
          system = "x86_64-linux";
          stateVersion = "22.05";
          homeModule = ({ config, pkgs, ... }: {
            imports = [
              ./home-manager/user-${user}.nix
              # ./home-manager/hyprland.nix # FIXME, swaylock, keybindings, ALT+TAB
            ];
            home.packages = with pkgs; [ discord kind restic slack zoom-us ];
            xresources.properties = { "Xft.dpi" = "109"; };
          });
        };

        karl-mba = mkHost "karl-mba" rec {
          inherit nixpkgs home-manager configRev user;
          system = "aarch64-linux";
          stateVersion = "23.11";
          extraModules = appleModules;
          overlays = [
            inputs.neovim-nightly-overlay.overlay
          ];
          homeModule = ({ config, pkgs, ... }: {
            imports = [ ./home-manager/user-${user}.nix ];
            # TODO, unsupported
            # home.packages = with pkgs; [ discord slack ];
            # home.pointerCursor.size = 180; # 4k
            home.pointerCursor.size = 128;
            xresources.properties = { "Xft.dpi" = "109"; };
          });
        };

        shub = mkHost "shub" rec {
          inherit nixpkgs home-manager overlays extraModules configRev user;
          system = "x86_64-linux";
          stateVersion = "22.05";
          homeModule = ({ config, pkgs, ... }: {
            imports = [ ./home-manager/user-${user}.nix ];
            home.packages = with pkgs; [ tmux ];
          });
        };

        tl = mkHost "tl" rec {
          inherit nixpkgs home-manager overlays extraModules configRev user;
          system = "x86_64-linux";
          stateVersion = "22.05";
          homeModule = ({ config, pkgs, ... }: {
            imports = [ ./home-manager/user-${user}.nix ];
            xresources.properties = { "Xft.dpi" = "109"; }; # 180 on 4k
          });
        };

      };
    };
}

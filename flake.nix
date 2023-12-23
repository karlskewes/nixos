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

    # Nightly on 0.10.0 which is not supported by nvim-treesitter yet.
    # neovim-nightly-overlay = {
    # url = "github:nix-community/neovim-nightly-overlay";
    # Pin to a nixpkgs revision that doesn't have NixOS/nixpkgs#208103 yet
    # inputs.nixpkgs.url =
    # "github:nixos/nixpkgs?rev=fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
    # };

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;
  };

  outputs = { self, home-manager, nixpkgs, apple-silicon-support, nix-extra, ...
    }@inputs:
    let
      # Overlays is the list of overlays we want to apply from flake inputs.
      #   overlays = [ inputs.neovim-nightly-overlay.overlay ];
      overlays = [ ];

      # Function to render out our hosts
      mkHost = import ./lib/mkHost.nix;

      # Let 'nixos-version --json' know about the Git revision
      configRev = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;

      user = "karl";
      emailAddress = "hello@karlskewes.com";
      stateVersion = "22.05";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew hello@karlskewes.com"
      ];
      hmModules = [
        ./home-manager/base.nix
        ./home-manager/dev.nix
        ./home-manager/xwindows.nix
      ];
      nixosModules = [
        "${nix-extra.outPath}/nixos.nix"
        ./system/base.nix
        ./system/xserver.nix
      ];

      appleOverlays = [ apple-silicon-support.overlays.default ];

    in {
      nixosConfigurations = {
        karl-desktop = mkHost "karl-desktop" rec {
          inherit nixpkgs home-manager nix-extra overlays configRev user
            emailAddress stateVersion authorizedKeys;
          system = "x86_64-linux";
          extraModules = nixosModules
            ++ [ ./system/libvirtd.nix ./system/zfs.nix ];
          homeConfig = ({ config, pkgs, ... }: {
            imports = hmModules;
            home.packages = with pkgs; [ discord kind restic slack zoom-us ];
            xresources.properties = { "Xft.dpi" = "109"; };
          });
        };

        blake-laptop = mkHost "blake-laptop" rec {
          inherit nixpkgs home-manager nix-extra overlays configRev user
            emailAddress stateVersion authorizedKeys;
          system = "x86_64-linux";
          extraModules = nixosModules ++ [ ./system/zfs.nix ];
          homeConfig = ({ config, pkgs, ... }: {
            imports = hmModules;
            home.packages = with pkgs; [ ];
            xresources.properties = { "Xft.dpi" = "96"; };
          });
        };

        karl-mba = mkHost "karl-mba" rec {
          inherit nixpkgs home-manager nix-extra configRev user emailAddress
            authorizedKeys;
          system = "aarch64-linux";
          overlays = [ apple-silicon-support.overlays.default ];
          stateVersion = "23.11";
          extraModules = nixosModules;
          homeConfig = ({ config, pkgs, ... }: {
            imports = hmModules;
            # TODO, unsupported
            # home.packages = with pkgs; [ discord slack ];
            # xresources.properties = { "Xft.dpi" = "96"; };
          });
        };

        shub = mkHost "shub" rec {
          inherit nixpkgs home-manager nix-extra overlays configRev user
            emailAddress stateVersion authorizedKeys;
          system = "x86_64-linux";
          extraModules = nixosModules ++ [ ./system/zfs.nix ];
          homeConfig = ({ config, pkgs, ... }: {
            imports = hmModules;
            home.packages = with pkgs; [ tmux ];
          });
        };

        tl = mkHost "tl" rec {
          inherit nixpkgs home-manager nix-extra overlays configRev user
            emailAddress stateVersion authorizedKeys;
          system = "x86_64-linux";
          extraModules = nixosModules ++ [ ./system/zfs.nix ];
          homeConfig = ({ config, pkgs, ... }: {
            imports = hmModules;
            home.packages = with pkgs; [
              slack

              envsubst
              buf
              mockgen # go generate mocks
              protobuf # protoc
              protoc-gen-go
              protoc-gen-go-grpc
              # protoc-gen-grpc-web
              # grpc-gateway
              protolint

              golangci-lint
              goose # https://github.com/pressly/goose
              nats-server
              # natscli
              postgresql_15

              nodejs
              yarn

              awscli2
              aws-vault
              packer
              terraform

              jq
            ];
            # home.pointerCursor.size = 180; # 4k
            xresources.properties = { "Xft.dpi" = "109"; }; # 180 on 4k
          });
        };

      };
    };
}

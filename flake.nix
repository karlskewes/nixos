{
  description = "NixOS Flake";

  inputs = {
    # use unstable by default for freshest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    vague-nvim = {
      url = "github:vague2k/vague.nvim";
      flake = false;
    };

    everforest-nvim = {
      url = "github:neanias/everforest-nvim";
      flake = false;
    };

    lackluster-nvim = {
      url = "github:slugbyte/lackluster.nvim";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # tell home-manager to use same packages as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
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
      inputs.nixpkgs.follows = "nixpkgs";
      # Pin to a nixpkgs revision that doesn't have NixOS/nixpkgs#208103 yet
      # inputs.nixpkgs.url =
      # "github:nixos/nixpkgs?rev=fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
    };

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;
  };

  outputs = { self, home-manager, nixpkgs, nix-darwin, apple-silicon-support
    , nix-extra, ... }@inputs:
    let
      extraNeovimPlugins = (self: super:
        let
          everforest-nvim = super.vimUtils.buildVimPlugin {
            name = "everforest-nvim";
            src = inputs.everforest-nvim;
          };
          lackluster-nvim = super.vimUtils.buildVimPlugin {
            name = "lackluster-nvim";
            src = inputs.lackluster-nvim;
          };
          vague-nvim = super.vimUtils.buildVimPlugin {
            name = "vague-nvim";
            src = inputs.vague-nvim;
          };
        in {
          vimPlugins = super.vimPlugins // {
            inherit everforest-nvim lackluster-nvim vague-nvim;
          };
        });

      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays =
        [ inputs.neovim-nightly-overlay.overlays.default extraNeovimPlugins ];

      # Function to render out our hosts
      mkHost = import ./lib/mkHost.nix;

      # Let 'nixos-version --json' know about the Git revision
      configRev = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;

      user = "karl";
      extraModules = [ "${nix-extra.outPath}/nixos.nix" ];
      appleModules = extraModules
        ++ [ apple-silicon-support.nixosModules.apple-silicon-support ];

    in {
      darwinConfigurations = {
        karl-mba = mkHost "karl-mba" {
          inherit nixpkgs nix-darwin home-manager overlays configRev;
          isDarwin = true;
          user = "karlskewes";
          system = "aarch64-darwin";
          stateVersion = "23.11";
        };
      };
      nixosConfigurations = {
        blake-laptop = mkHost "blake-laptop" {
          inherit nixpkgs home-manager overlays extraModules configRev user;
          system = "x86_64-linux";
          stateVersion = "22.05";
        };

        karl-mba = mkHost "karl-mba" {
          inherit nixpkgs home-manager configRev user;
          system = "aarch64-linux";
          stateVersion = "23.11";
          extraModules = appleModules;
          overlays = [
            apple-silicon-support.overlays.apple-silicon-overlay
            inputs.neovim-nightly-overlay.overlays.default
            extraNeovimPlugins
          ];
        };

        tiny = mkHost "tiny" {
          inherit nixpkgs home-manager overlays extraModules configRev user;
          system = "x86_64-linux";
          stateVersion = "22.05";
        };

        tl = mkHost "tl" {
          inherit nixpkgs home-manager overlays extraModules configRev user;
          system = "x86_64-linux";
          stateVersion = "22.05";
        };

      };
    };
}

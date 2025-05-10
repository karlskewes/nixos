{
  description = "NixOS Flake";

  inputs = {
    # use unstable by default for freshest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.follows =
    #   "nixos-cosmic/nixpkgs"; # NOTE: change "nixpkgs" to "nixpkgs-stable" to use stable NixOS release

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

    namu-nvim = {
      url = "github:bassamsdata/namu.nvim";
      flake = false;
    };

    telescope-hierarchy-nvim = {
      url = "github:jmacadie/telescope-hierarchy.nvim";
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

    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
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
          customPlugins = {
            namu-nvim = super.vimUtils.buildVimPlugin {
              name = "namu-nvim";
              src = inputs.namu-nvim;
            };
            telescope-hierarchy-nvim = super.vimUtils.buildVimPlugin {
              name = "telescope-hierarchy-nvim";
              src = inputs.telescope-hierarchy-nvim;
            };
          };
        in { vimPlugins = super.vimPlugins // customPlugins; });

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

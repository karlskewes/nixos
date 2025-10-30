{
  description = "NixOS Flake";

  inputs = {
    # use unstable by default for freshest packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    namu-nvim = {
      url = "github:bassamsdata/namu.nvim";
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

    # TODO: switch to heavily restricted module: https://github.com/GarrettGR/titdb-nix
    # https://github.com/tascvh/trackpad-is-too-damn-big/compare/main...luqmanishere:trackpad-is-too-damn-big:main
    titdb = {
      url =
        "github:luqmanishere/trackpad-is-too-damn-big-flake?rev=9712b426311195c8d3f0359c6086e1d651782d2e";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-silicon-support = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      # Pin to a nixpkgs revision that doesn't have NixOS/nixpkgs#208103 yet
      # inputs.nixpkgs.url =
      # "github:nixos/nixpkgs?rev=fad51abd42ca17a60fc1d4cb9382e2d79ae31836";
    };

    kolide-launcher = {
      url = "github:/kolide/nix-agent/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;
  };

  outputs = { self, home-manager, nixpkgs, nix-darwin, apple-silicon-support
    , titdb, kolide-launcher, nix-extra, ... }@inputs:
    let
      extraNeovimPlugins = (self: super:
        let
          customPlugins = {
            namu-nvim = super.vimUtils.buildVimPlugin {
              name = "namu-nvim";
              src = inputs.namu-nvim;
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
      appleModules = extraModules ++ [
        apple-silicon-support.nixosModules.apple-silicon-support
        titdb.nixosModules.default
        {
          services.titdb = {
            enable = true;
            # udevadm info /dev/input/event* | grep -E '(DEVNAME|TOUCHPAD)'
            # Use `by-path/` instead of `/dev/input/event#` to consistently target the correct device
            # as `event#` numbers can change.
            # $ ls /dev/input/by-path/plat form-23510c000.spi-cs-0-event-mouse -la
            # lrwxrwxrwx 1 root root 9 Oct 27 08:43 /dev/input/by-path/platform-23510c000.spi-cs-0-event-mouse -> ../event2
            device =
              "/dev/input/by-path/platform-23510c000.spi-cs-0-event-mouse";
          };
        }
      ];
      vmModules = extraModules
        ++ [ kolide-launcher.nixosModules.kolide-launcher ];

    in {
      darwinConfigurations = {
        gl = mkHost "gl" {
          inherit nixpkgs nix-darwin home-manager overlays configRev;
          isDarwin = true;
          user = "karlskewes";
          system = "aarch64-darwin";
          stateVersion = "25.05";
        };
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

        gl-vm = mkHost "gl-vm" {
          inherit nixpkgs home-manager overlays configRev user;
          system = "aarch64-linux";
          stateVersion = "25.05";
          extraModules = vmModules;
        };

        tiny = mkHost "tiny" {
          inherit nixpkgs home-manager overlays extraModules configRev user;
          system = "x86_64-linux";
          stateVersion = "22.05";
        };

      };
    };
}

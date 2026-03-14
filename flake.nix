{
  description = "NixOS Flake";

  inputs = {
    # .url conventions
    # github:org/repo => primary branch, e.g: main or master
    # github:org/repo/custom_branch => custom_branch
    # github:org/repo?rev=ABC => commit ABC

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
      url = "github:luqmanishere/trackpad-is-too-damn-big-flake?rev=9712b426311195c8d3f0359c6086e1d651782d2e";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-silicon-support = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      # Override tree-sitter to use v0.26.6 from our tree-sitter input
      inputs.neovim-dependencies.inputs.treesitter.follows = "tree-sitter";
    };

    kolide-launcher = {
      url = "github:/kolide/nix-agent/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;

    tree-sitter = {
      url = "github:tree-sitter/tree-sitter/release-0.26";
      # tree-sitter has its own flake, use it!
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      nix-darwin,
      apple-silicon-support,
      titdb,
      kolide-launcher,
      nix-extra,
      ...
    }@inputs:
    let
      extraNeovimPlugins = (
        self: super:
        let
          customPlugins = {
            namu-nvim = super.vimUtils.buildVimPlugin {
              name = "namu-nvim";
              src = inputs.namu-nvim;
            };
          };
        in
        {
          vimPlugins = super.vimPlugins // customPlugins;
        }
      );

      # Apply Darwin-specific gdb patch
      gdbDarwinPatch = (
        self: super:
        super.lib.optionalAttrs super.stdenv.isDarwin {
          gdb = super.gdb.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or [ ]) ++ [
              ./home-manager/modules/gdb-tic4x-darwin.patch
            ];
            configureFlags = (oldAttrs.configureFlags or [ ]) ++ [
              (super.lib.enableFeature false "werror")
            ];
          });
        }
      );

      # Add tree-sitter v0.26.6 CLI for nvim-treesitter plugin
      treeSitterCLI = (
        self: super: {
          tree-sitter-latest = inputs.tree-sitter.packages.${super.stdenv.hostPlatform.system}.cli;
        }
      );

      # Override example-app, build once to get src.hash, then repeat for cargoHash:
      #   nix build .#nixosConfigurations.$HOSTNAME.config.system.build.toplevel
      # exampleAppOverlay = final: prev: {
      #   example-app = prev.example-app.overrideAttrs (old: {
      #     src = prev.fetchFromGitHub {
      #       owner = "your-github-user";
      #       repo = "example-app";
      #       rev = "my-branch";
      #       hash = prev.lib.fakeSha256;
      #     };
      #
      #     cargoHash = prev.lib.fakeSha256;
      #   });
      # };

      # Cosmic DE Window Assignment Development, override package set so dependencies managed together.
      # $ nix eval .#nixosConfigurations.karl-mba.pkgs.cosmic-comp.src
      # /home/karl/src/github.com/karlskewes/cosmic-comp
      # Validate version
      # $ nix eval .#nixosConfigurations.karl-mba.pkgs.cosmic-settings-daemon.version
      # "local-dev"
      #
      # cosmicOverlay2 =
      #   final: prev:
      #   let
      #     overrideCosmic =
      #       pname: pkg: cargoDepsHash:
      #       let
      #         repoPath = "/home/karl/src/github.com/karlskewes/${pname}";
      #       in
      #       if builtins.pathExists repoPath then
      #         pkg.overrideAttrs (_: {
      #           src = prev.lib.cleanSource repoPath;
      #           cargoDeps = prev.rustPlatform.fetchCargoVendor {
      #             src = prev.lib.cleanSource repoPath;
      #             hash = cargoDepsHash; # use "" for first build.
      #           };
      #           cargoHash = prev.lib.fakeSha256;
      #           version = "local-dev";
      #         })
      #       else
      #         pkg;
      #   in
      #   {
      #     cosmic-comp =
      #       overrideCosmic "cosmic-comp" prev.cosmic-comp
      #         "sha256-rXaKLTNtQjIgGeO9nHHA5JjhcLqdO8xwhVjxd43IpKo=";
      #     cosmic-settings-daemon =
      #       overrideCosmic "cosmic-settings-daemon" prev.cosmic-settings-daemon
      #         "sha256-I4pzDq3NoKQsiadiwgA1CIfFE2Sfo+hbUUlrTjFG5x0=";
      #   };

      # cosmicOverlay = final: prev: {
      #   cosmic-comp = prev.cosmic-comp.overrideAttrs (_: {
      #     src = prev.fetchFromGitHub {
      #       owner = "karlskewes";
      #       repo = "cosmic-comp";
      #       rev = "workspace-pinning"; # commit SHA or branch
      #       # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # fake to get started
      #       hash = "sha256-4RDUW6vfHOHfQolAF70C0mYxU0/eChghvE8L6YF9bAU=";
      #     };
      #     cargoHash = prev.lib.fakeSha256;
      #     # cargoHash = "";
      #     version = "workspace-pinning";
      #   });
      #   cosmic-settings-daemon = prev.cosmic-settings-daemon.overrideAttrs (_: {
      #     src = prev.fetchFromGitHub {
      #       owner = "karlskewes";
      #       repo = "cosmic-settings-daemon";
      #       rev = "workspace-pinning"; # commit SHA or branch
      #       # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      #       hash = "sha256-mofV6VFG7w3JfriAOpY8FQAw68C5uQZErWx2K6GHMaY=";
      #     };
      #     # cargoHash = prev.lib.fakeSha256;
      #     cargoHash = "";
      #     version = "workspace-pinning";
      #   });
      # };

      githubOrgPath = "/home/karl/src/github.com/karlskewes";

      # NOTE: dependencies between overridden applications defined in Cargo.toml must be
      # git and not local paths due to nix store offline mode plus potentially other issues.
      # push changes to git, ensure Cargo.lock updated and do `hash = ""; hash = "sha-real-thing";` loop.
      cosmicOverlay = final: prev: {
        cosmic-comp = prev.cosmic-comp.overrideAttrs (_: {
          doCheck = false; # skip checks after build whilst iterating.
          doInstallCheck = false;
          src = prev.lib.cleanSource "${githubOrgPath}/cosmic-comp";
          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            src = prev.lib.cleanSource "${githubOrgPath}/cosmic-comp";
            hash = "sha256-JYL571a5VPwO694sp4FY7PROumE58epRO8SDTcJjlD0=";
            # hash = ""; # set whenever source changes to trigger fresh build.
          };
          cargoHash = prev.lib.fakeSha256;
          version = "local-dev";
        });
        cosmic-settings-daemon = prev.cosmic-settings-daemon.overrideAttrs (_: {
          doCheck = false; # skip checks after build whilst iterating.
          doInstallCheck = false;
          src = prev.lib.cleanSource "${githubOrgPath}/cosmic-settings-daemon";

          cargoDeps = prev.rustPlatform.fetchCargoVendor {
            src = prev.lib.cleanSource "${githubOrgPath}/cosmic-settings-daemon";
            hash = "sha256-I4pzDq3NoKQsiadiwgA1CIfFE2Sfo+hbUUlrTjFG5x0=";
            # hash = ""; # set whenever source changes to trigger fresh build.
          };
          cargoHash = prev.lib.fakeSha256;
          version = "local-dev";
        });
      };

      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
        extraNeovimPlugins
        gdbDarwinPatch
        treeSitterCLI
      ];

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
            device = "/dev/input/by-path/platform-23510c000.spi-cs-0-event-mouse";
          };
        }
      ];

    in
    {
      darwinConfigurations = {
        gl = mkHost "gl" {
          inherit
            nixpkgs
            nix-darwin
            home-manager
            overlays
            configRev
            ;
          isDarwin = true;
          user = "karlskewes";
          system = "aarch64-darwin";
          stateVersion = "25.05";
        };
        gm = mkHost "gm" {
          inherit
            nixpkgs
            nix-darwin
            home-manager
            overlays
            configRev
            ;
          isDarwin = true;
          user = "karlskewes";
          system = "aarch64-darwin";
          stateVersion = "25.11";
        };
        karl-mba = mkHost "karl-mba" {
          inherit
            nixpkgs
            nix-darwin
            home-manager
            overlays
            configRev
            ;
          isDarwin = true;
          user = "karlskewes";
          system = "aarch64-darwin";
          stateVersion = "23.11";
        };
      };

      nixosConfigurations = {
        blake-laptop = mkHost "blake-laptop" {
          inherit
            nixpkgs
            home-manager
            overlays
            extraModules
            configRev
            user
            ;
          system = "x86_64-linux";
          stateVersion = "22.05";
        };

        karl-mba = mkHost "karl-mba" {
          inherit
            nixpkgs
            home-manager
            configRev
            user
            ;
          system = "aarch64-linux";
          stateVersion = "23.11";
          extraModules = appleModules;
          overlays = [
            apple-silicon-support.overlays.apple-silicon-overlay
            inputs.neovim-nightly-overlay.overlays.default
            extraNeovimPlugins
            # cosmicOverlay # TODO: enable
          ];
        };

        gl-vm = mkHost "gl-vm" {
          inherit
            nixpkgs
            home-manager
            overlays
            configRev
            user
            ;
          system = "aarch64-linux";
          stateVersion = "25.05";
          extraModules = extraModules ++ [ kolide-launcher.nixosModules.kolide-launcher ];
        };

        gm = mkHost "gm" {
          inherit
            nixpkgs
            home-manager
            configRev
            user
            ;
          system = "aarch64-linux";
          stateVersion = "25.11";
          extraModules = appleModules ++ [ kolide-launcher.nixosModules.kolide-launcher ];
          overlays = [
            apple-silicon-support.overlays.apple-silicon-overlay
            inputs.neovim-nightly-overlay.overlays.default
            extraNeovimPlugins
          ];
        };

        tiny = mkHost "tiny" {
          inherit
            nixpkgs
            home-manager
            overlays
            extraModules
            configRev
            user
            ;
          system = "x86_64-linux";
          stateVersion = "22.05";
        };

      };
    };
}

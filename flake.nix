{
  description = "NixOS Flake";

  inputs = {
    # use unstable by default for freshest packages, pin stable if need be.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-21.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # tell home-manager to use same packages as nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:mjlbach/neovim-nightly-overlay";

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;
  };

  # pass all inputs to outputs
  outputs = { self, ... }@inputs:
    let

      # shared between home-manager and nixos
      system = "x86_64-linux";

      # Home Manager
      # https://github.com/nix-community/home-manager/blob/3d46c011d2cc2c9ca24d9b803e9daf156d9429ea/flake.nix#L54
      username = "karl";
      homeDirectory = "/home/${username}";
      stateVersion = "21.11";

      emailAddress = "karl.skewes@gmail.com";

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
      nixos-stable-overlay = final: prev: {
        stable = inputs.nixpkgs-stable.legacyPackages.${system};
      };
      overlaysCommon =
        [ nixos-stable-overlay inputs.neovim-nightly-overlay.overlay ];

      # NixOS
      modulesCommon = [
        "${inputs.nix-extra.outPath}/nixos.nix"
        ./machines/base.nix
        ./machines/xserver.nix
      ];

    in {
      homeManagerConfigurations = {
        karl-desktop = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs username homeDirectory stateVersion;
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = overlaysCommon;
            imports = importsCommon;
            home.packages = with pkgs; [ discord slack kind ];
            xresources.properties = { "Xft.dpi" = "109"; };
            programs.git.userEmail = emailAddress;
          };
        };

        karl-laptop = inputs.home-manager.lib.homeManagerConfiguration {
          inherit system pkgs username homeDirectory stateVersion;
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = overlaysCommon;
            imports = importsCommon;
            home.packages = with pkgs; [ discord slack ];
            xresources.properties = { "Xft.dpi" = "96"; };
            programs.git.userEmail = emailAddress;
          };
        };

        rpi = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs username homeDirectory stateVersion;
          system = "aarch64-linux";
          configuration = { config, pkgs, ... }: {
            nixpkgs.overlays = overlaysCommon;
            imports = importsCommon;
            home.packages = with pkgs; [ ];
            xresources.properties = { "Xft.dpi" = "64"; };
            programs.git.userEmail = emailAddress;
          };
        };

      };

      nixosConfigurations = {
        karl-desktop = lib.nixosSystem {
          inherit system;
          modules = modulesCommon ++ [
            ./machines/karl-desktop.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "f299660e";
              networking.hostName = "karl-desktop";
              networking.interfaces.enp9s0.useDHCP = true;
              nixpkgs.config.allowUnfree = true; # memtest86+
              hardware.opengl.extraPackages = with pkgs; [
                rocm-opencl-icd
                rocm-opencl-runtime
              ];
              services.xserver.videoDrivers = [ "amdgpu" ];
            })
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # TODO: consider moving home-manager config to nixos module - build as one
              #   home-manager.users.karl = {
              #     home.username = "karl";
              #     home.homeDirectory = "/home/karl";
              #     home. = "21.05"; # HACK for version mismatch error
              #     # nixpkgs.overlays = overlaysCommon;
              #     # imports = importsCommon;
              #     # home.packages = with pkgs; [ discord slack ];
              #     xresources.properties = { "Xft.dpi" = "109"; };
              #     home.pointerCursor.size = 64;
              #   };
            }
          ];
        };

        karl-laptop = lib.nixosSystem {
          inherit system;
          modules = modulesCommon ++ [
            ./machines/karl-laptop.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "624e2a63";
              networking.hostName = "karl-laptop";
              networking.networkmanager.enable = true;
              nixpkgs.config.allowUnfree = true; # memtest86+
              nixpkgs.config.packageOverrides = pkgs: {
                vaapiIntel =
                  pkgs.vaapiIntel.override { enableHybridCodec = true; };
              };
              hardware.opengl.extraPackages = with pkgs; [
                intel-media-driver # LIBVA_DRIVER_NAME=iHD
                vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
                vaapiVdpau
                libvdpau-va-gl
              ];
              # Need full for bluetooth support
              hardware.pulseaudio.package = pkgs.pulseaudioFull;
            })
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

        rpi = lib.nixosSystem {
          system = "aarch64-linux";
          modules = modulesCommon ++ [
            ./machines/rpi.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision = lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "c3f22703";
              networking.hostName = "rpi";
              networking.networkmanager.enable = true;
              nixpkgs.config.allowUnfree = true; # memtest86+
              # https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3
              boot.kernelParams = [ "console=ttyS1,115200n8" ];
              boot.loader.raspberryPi.firmwareConfig = ''
                dtparam=audio=on
              '';
              hardware.enableRedistributableFirmware = true;
              # additional configuration required to enable bluetooth
            })
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

      };
    };
}

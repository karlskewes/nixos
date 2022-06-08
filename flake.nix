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
    neovim-nightly-overlay.url = "github:mjlbach/neovim-nightly-overlay";

    nix-extra.url = "path:/home/karl/src/nix-extra";
    nix-extra.flake = false;
  };

  # pass all inputs to outputs
  outputs = { self, ... }@inputs:
    let
      # Home Manager
      # https://github.com/nix-community/home-manager/blob/3d46c011d2cc2c9ca24d9b803e9daf156d9429ea/flake.nix#L54
      username = "karl";
      emailAddress = "karl.skewes@gmail.com";
      importsCommon = [
        ./home-manager/base.nix
        ./home-manager/dev.nix
        ./home-manager/xwindows.nix
      ];

      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        # required for chrome, perhaps could move elsewhere per machine/group
        config = { allowUnfree = true; };
        overlays = [ inputs.neovim-nightly-overlay.overlay ];
      };

      pkgsArm = import inputs.nixpkgs {
        system = "aarch64-linux";
        # required for chrome, perhaps could move elsewhere per machine/group
        config = { allowUnfree = true; };
        overlays = [ inputs.neovim-nightly-overlay.overlay ];
      };

      modulesCommon = [
        "${inputs.nix-extra.outPath}/nixos.nix"
        ./machines/base.nix
        ./machines/xserver.nix
      ];

    in {
      nixosConfigurations = {
        karl-desktop = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit pkgs;
          modules = modulesCommon ++ [
            ./machines/karl-desktop.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision =
                inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "f299660e";
              networking.hostName = "karl-desktop";
              networking.interfaces.enp9s0.useDHCP = true;
              hardware.opengl.extraPackages = with pkgs; [
                rocm-opencl-icd
                rocm-opencl-runtime
              ];
              services.xserver.videoDrivers = [ "amdgpu" ];
              # enable building aarch64 image
              boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
            })
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = {
                imports = importsCommon;
                home.packages = with pkgs; [
                  delve
                  discord
                  google-chrome
                  kind
                  slack
                ];
                xresources.properties = { "Xft.dpi" = "109"; };
              };
            }
          ];
        };

        karl-laptop = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit pkgs;
          modules = modulesCommon ++ [
            ./machines/karl-laptop.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision =
                inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "624e2a63";
              networking.hostName = "karl-laptop";
              networking.networkmanager.enable = true;
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
              home-manager.users.${username} = {
                imports = importsCommon;
                home.packages = with pkgs; [
                  delve
                  google-chrome
                  discord
                  slack
                ];
                xresources.properties = { "Xft.dpi" = "96"; };
              };
            }
          ];
        };

        rpi = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          pkgs = pkgsArm;
          modules = modulesCommon ++ [
            ./machines/rpi.nix
            ({ config, ... }: {
              # Let 'nixos-version --json' know about the Git revision
              system.configurationRevision =
                inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;
              # Define hostId for zfs pool machine 'binding'
              # :read !head -c4 /dev/urandom | od -A none -t x4
              networking.hostId = "c3f22703";
              networking.hostName = "rpi";
              networking.networkmanager.enable = true;
              environment.systemPackages = with pkgsArm; [ raspberrypi-tools ];

              # https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3
              boot.consoleLogLevel = inputs.nixpkgs.lib.mkDefault 7;
              boot.kernelParams = [ "console=ttyS1,115200n8" ];
              boot.kernelPackages = pkgsArm.linuxPackages_rpi3;
              boot.loader.grub.enable = false;
              boot.loader.generic-extlinux-compatible.enable = true;
              boot.loader.raspberryPi.enable = true;
              boot.loader.raspberryPi.version = 3;
              boot.loader.raspberryPi.uboot.enable = true;
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
              home-manager.users.${username} = {
                imports = importsCommon;
                xresources.properties = { "Xft.dpi" = "64"; };
              };
            }
          ];
        };
      };
    };
}

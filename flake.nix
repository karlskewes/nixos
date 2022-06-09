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

  outputs = { self, home-manager, nixpkgs, nix-extra, ... }@inputs:
    let
      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = [ inputs.neovim-nightly-overlay.overlay ];

      # Function to render out our hosts
      mkHost = import ./mkHost.nix;

      # Let 'nixos-version --json' know about the Git revision
      configRev = inputs.nixpkgs.lib.mkIf (self ? rev) self.rev;

      user = "karl";
      emailAddress = "karl.skewes@gmail.com";
      # TODO: move imports into mkHost.nix
      importsCommon = [
        ./home-manager/base.nix
        ./home-manager/dev.nix
        ./home-manager/xwindows.nix
      ];

    in {
      nixosConfigurations = {
        karl-desktop = mkHost "karl-desktop" rec {
          inherit nixpkgs home-manager overlays nix-extra user emailAddress;
          system = "x86_64-linux";
          machineConfig = ({ config, pkgs, ... }: {
            system.configurationRevision = configRev;
            # Define hostId for zfs pool machine 'binding'
            # :read !head -c4 /dev/urandom | od -A none -t x4
            networking.hostId = "f299660e";
            networking.interfaces.enp9s0.useDHCP = true;
            hardware.opengl.extraPackages = with pkgs; [
              rocm-opencl-icd
              rocm-opencl-runtime
            ];
            services.xserver.videoDrivers = [ "amdgpu" ];
            # enable building aarch64 image
            boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          });
          homeConfig = ({ config, pkgs, ... }: {
            imports = importsCommon;
            home.packages = with pkgs; [
              delve
              discord
              google-chrome
              kind
              slack
            ];
            xresources.properties = { "Xft.dpi" = "109"; };
          });
        };

        karl-laptop = mkHost "karl-laptop" rec {
          inherit nixpkgs home-manager overlays nix-extra user emailAddress;
          system = "x86_64-linux";
          machineConfig = ({ config, pkgs, ... }: {
            system.configurationRevision = configRev;
            # Define hostId for zfs pool machine 'binding'
            # :read !head -c4 /dev/urandom | od -A none -t x4
            networking.hostId = "624e2a63";
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
          });
          homeConfig = ({ config, pkgs, ... }: {
            imports = importsCommon;
            home.packages = with pkgs; [ delve google-chrome discord slack ];
            xresources.properties = { "Xft.dpi" = "96"; };
          });
        };

        rpi = mkHost "rpi" rec {
          inherit nixpkgs home-manager overlays nix-extra user emailAddress;
          system = "aarch64-linux";
          machineConfig = ({ config, pkgs, ... }: {
            system.configurationRevision = configRev;
            # Define hostId for zfs pool machine 'binding'
            # :read !head -c4 /dev/urandom | od -A none -t x4
            networking.hostId = "c3f22703";
            networking.networkmanager.enable = true;
            environment.systemPackages = with pkgs; [ libraspberrypi ];
            # https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3
            hardware.enableRedistributableFirmware = true;
            # additional configuration required to enable bluetooth
          });
          homeConfig = ({ config, pkgs, ... }: {
            imports = importsCommon;
            xresources.properties = { "Xft.dpi" = "64"; };
          });
        };
      };
    };
}

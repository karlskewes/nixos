{ config, pkgs, ... }: {

  imports = [ ./base.nix ./i3.nix ./zfs.nix ];

  boot.zfs.removeLinuxDRM = true;
  virtualisation.docker = {
    storageDriver = "overlay";
  }; # TODO, change after migrate to ZFS

  powerManagement.enable = true;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "b4db4b8f";

  # Specify path to peripheral firmware files copied during initial
  # installation.
  sound.enable = true;
  hardware.asahi = {
    peripheralFirmwareDirectory = /etc/nixos/firmware;
    withRust = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
  };
  # Or disable extraction and management of them completely (no wifi though).
  # hardware.asahi.extractPeripheralFirmware = false;

  # broken 2024-07-15
  # services.clamav = {
  #   daemon.enable = true;
  #   updater.enable = true;
  # };

  # dock "displaylink" driver must be manually installed, see run.sh
  # TODO: convert to nix
  # modesetting required I think for actual display output to dock
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  services.logind.lidSwitch = "suspend";

  # defined here so LightDM is started after autorandr and thus login screen
  # shows on correct monitor.
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.autorandr}/bin/autorandr primary
  '';
  services.autorandr = {
    enable = true;
    defaultTarget = "primary"; # laptop lid normally open
    profiles = {
      # list profiles with `autorandr`, switch `autorandr both`
      both = {
        config = {
          # autorandr --config
          eDP-1 = {
            enable = true;
            mode = "2560x1600";
            primary = true;
            position = "0x0";
            rate = "60.00";
            dpi = 109;
          };
          DVI-I-1-1 = {
            enable = true;
            mode = "2560x1440";
            position = "2560x0";
            rate = "144.00";
            dpi = 109;
            crtc = 0;
          };
        };
        fingerprint = {
          # nix-shell -p autorandr
          # autorandr --fingerprint
          eDP-1 = "--CONNECTED-BUT-EDID-UNAVAILABLE--eDP-1";
          DVI-I-1-1 =
            "00ffffffffffff005a6338a76e040000211e0103803c22782ee640ac4f44ad270c5054bfef80d1c0b300a940a9c095009040818081c0565e00a0a0a029503020350056502100001a000000fd00304b1e731f000a202020202020000000fc005658323735382d536572696573000000ff005656463230333330313133340a01a302032df14f900504030207121314161f20212201230907078301000067030c0010003840681a00000101304ced023a801871382d40582c450056502100001e011d8018711c1620582c250056502100009e011d007251d01e206e28550056502100001ebd7600a0a0a032503020350056502100001e0000000000000000000091";
        };
      };
      external = {
        config = {
          "eDP-1".enable = false;
          DVI-I-1-1 = {
            enable = true;
            mode = "2560x1440";
            position = "0x0";
            primary = true;
            rate = "144.00";
            dpi = 109;
            crtc = 0;
          };
        };
        fingerprint = {
          eDP-1 = "--CONNECTED-BUT-EDID-UNAVAILABLE--eDP-1";
          DVI-I-1-1 =
            "00ffffffffffff005a6338a76e040000211e0103803c22782ee640ac4f44ad270c5054bfef80d1c0b300a940a9c095009040818081c0565e00a0a0a029503020350056502100001a000000fd00304b1e731f000a202020202020000000fc005658323735382d536572696573000000ff005656463230333330313133340a01a302032df14f900504030207121314161f20212201230907078301000067030c0010003840681a00000101304ced023a801871382d40582c450056502100001e011d8018711c1620582c250056502100009e011d007251d01e206e28550056502100001ebd7600a0a0a032503020350056502100001e0000000000000000000091";
        };
      };
      primary = {
        config = {
          eDP-1 = {
            enable = true;
            mode = "2560x1600";
            position = "0x0";
            primary = true;
            rate = "60.00";
            dpi = 109;
          };
        };
        fingerprint = { eDP-1 = "--CONNECTED-BUT-EDID-UNAVAILABLE--eDP-1"; };
      };
    };
  };

}

{ config, lib, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix

    ../common/global

    ../common/optional/i3.nix
    ../common/optional/zfs.nix
  ];

  zfsBootUnlock = {
    enable = false;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew hello@karlskewes.com"
    ];
    interfaces = [ "cdc-ncm" ];
  };

  boot.kernelParams = [
    "psmouse.synaptics_intertouch=0"
  ]; # Enables libinput settings to take effect.
  boot.zfs.removeLinuxDRM = true;
  virtualisation.docker = {
    storageDriver = lib.mkForce "overlay2";
  }; # TODO, change after migrate to ZFS

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "b4db4b8f";

  hardware.asahi = {
    enable = true;
    # Specify path to peripheral firmware files copied during initial installation.
    peripheralFirmwareDirectory = /etc/nixos/firmware;
    withRust = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
  };
  # Or disable extraction and management of them completely (no wifi though).
  # hardware.asahi.extractPeripheralFirmware = false;

  powerManagement.enable = true;

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  services.logind.lidSwitch = "suspend";

  # dock "displaylink" driver must be manually installed, see run.sh
  # TODO: convert to nix
  # modesetting required I think for actual display output to dock
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

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

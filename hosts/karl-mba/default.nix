{ lib, ... }:
{

  imports = [
    ./hardware-configuration.nix

    ../modules

    ../modules/cosmic.nix
    # ../modules/hyprland.nix
    # ../modules/zfs.nix
  ];

  boot.kernelParams = [
    "psmouse.synaptics_intertouch=0"
  ]; # Enables libinput settings to take effect.

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.luks.devices."crypted".allowDiscards = true; # SSD TRIM
  boot.initrd.kernelModules = [
    "cryptd"
    "dm-snapshot"
  ];
  boot.supportedFilesystems = [ "btrfs" ];
  # Set in ./hardware-configuration.nix
  # boot.initrd.luks.devices."crypted".device = { ... };

  hardware.asahi = {
    enable = true;
    # Specify path to peripheral firmware files copied during initial installation.
    peripheralFirmwareDirectory = /etc/nixos/firmware;
    setupAsahiSound = true;
  };

  # Or disable extraction and management of them completely (no wifi though).
  # hardware.asahi.extractPeripheralFirmware = false;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "b4db4b8f";
  networking.interfaces.wlan0.useDHCP = true;

  powerManagement.enable = true;

  services.clamav = {
    daemon.enable = true;
    clamonacc.enable = true;
    scanner.enable = false; # no need to scan whole filesystem every day (scanner.interval).
    updater.enable = true;
    daemon.settings = {
      OnAccessPrevention = true;
      OnAccessIncludePath = "/home/karl/Downloads";
      # exclude various package caches.
      "ExcludePath" = [
        "/node_modules/"
        "/go/"
        "/\\.rustup/"
        "/\\.yarn/"
        "/yarn/berry/"
      ];

      # $ journalctl -u clamdscan.service
      # `clamdscan[22040]: LibClamAV Warning: cli_realpath: Invalid arguments.`
      # $ cd DIRECTORY_TO_SCAN # cd /var/lib
      # $ find . | awk 'FS="/" {print(NF)}' | sort --general-numeric-sort | tail --lines 1
      # 26
      MaxDirectoryRecursion = 30;
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # services.logind.settings.Login.HandleLidSwitch = "suspend";

  # dock "displaylink" driver mustHandleLid manually installed, see run.sh
  # TODO: convert to nix
  # modesetting required I think for actual display output to dock
  # TODO: disable for hyprland
  # services.xserver.videoDrivers = [
  #   "displaylink"
  #   "modesetting"
  # ];

  virtualisation.docker = {
    storageDriver = lib.mkForce "overlay2";
  }; # TODO, change after migrate to ZFS

}

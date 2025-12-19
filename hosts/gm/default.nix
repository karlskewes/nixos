{ ... }: {

  imports = [
    ./hardware-configuration.nix

    ../modules

    ../modules/cosmic.nix
  ];

  users.users.karl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiGTZKrOJF/E+CvHZ0ZGgFOAACNRU2MuDP2YdYjAM2v"
  ];
  # networking.firewall.allowedTCPPorts = [ 3000 ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.luks.devices."crypted".allowDiscards = true; # SSD TRIM
  boot.initrd.kernelModules = [ "cryptd" "dm-snapshot" ];
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
  networking.hostId = "163f2f31";

  # Only one interface `eth0` and require name matching hardcoded upstream tests.
  networking.usePredictableInterfaceNames = false;
  # "eth0" predictable name per above, /proc/sys/net/ipv4/conf/eth0
  # journalctl -u systemd-sysctl.service
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  security.sudo.wheelNeedsPassword = true;

  # btrfs scrub status /
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  services.clamav = {
    daemon.enable = true;
    daemon.settings = {
      # exclude various package caches.
      "ExcludePath" =
        [ "/node_modules/" "/go/" "/\\.rustup/" "/\\.yarn/" "/yarn/berry/" ];

      # $ journalctl -u clamdscan.service
      # `clamdscan[22040]: LibClamAV Warning: cli_realpath: Invalid arguments.`
      # $ cd DIRECTORY_TO_SCAN # cd /var/lib
      # $ find . | awk 'FS="/" {print(NF)}' | sort --general-numeric-sort | tail --lines 1
      # 26
      MaxDirectoryRecursion = 30;
    };
    scanner.enable = true;
    updater.enable = true;
  };

  services.kolide-launcher = {
    enable = true;
    updateChannel = "stable";
  };

  services.tailscale.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
}

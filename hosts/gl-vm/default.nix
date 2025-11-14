{ ... }: {

  imports = [
    ./hardware-configuration.nix

    ../modules

    ../modules/cosmic.nix
    ../modules/zfs.nix
  ];

  zfsBootUnlock = {
    enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiGTZKrOJF/E+CvHZ0ZGgFOAACNRU2MuDP2YdYjAM2v"
    ];
    interfaces = [ "virtio_net" ]; # sudo dmesg | grep eth0
  };

  users.users.karl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiGTZKrOJF/E+CvHZ0ZGgFOAACNRU2MuDP2YdYjAM2v"
  ];
  # networking.firewall.allowedTCPPorts = [ 3000 ];

  # Suspect required for Apple Virtualization to boot. TBC.
  boot.loader.efi.canTouchEfiVariables = true;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "6e63a55c";

  # Only one interface `eth0` and require name matching hardcoded upstream tests.
  networking.usePredictableInterfaceNames = false;
  # "eth0" predictable name per above, /proc/sys/net/ipv4/conf/eth0
  # journalctl -u systemd-sysctl.service
  networking.interfaces.eth0.useDHCP = true;

  security.sudo.wheelNeedsPassword = true;

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

  # UTM Apple/QEMU guest integration - clipboard sharing/etc.
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  services.tailscale.enable = true;
  virtualisation.docker.enable = true;
}

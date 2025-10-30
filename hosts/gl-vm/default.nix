{ lib, pkgs, ... }: {

  imports = [
    ./hardware-configuration_apple.nix
    # ./hardware-configuration_qemu.nix

    ../common/global

    ../common/optional/cosmic.nix
    # ../common/optional/zfs.nix
  ];

  users.users.karl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiGTZKrOJF/E+CvHZ0ZGgFOAACNRU2MuDP2YdYjAM2v"
  ];
  # networking.firewall.allowedTCPPorts = [ 3000 ];

  # Suspect required for Apple Virtualization to boot. TBC.
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_17;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "6e63a55c";

  # Only one interface `eth0` and require name matching hardcoded upstream tests.
  networking.usePredictableInterfaceNames = false;

  security.sudo.wheelNeedsPassword = true;

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  services.kolide-launcher = {
    enable = true;
    updateChannel = "stable";
  };

  # UTM Apple/QEMU guest integration - clipboard sharing/etc.
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  virtualisation.docker = {
    storageDriver = lib.mkForce "overlay2";
  }; # TODO, change after migrate to ZFS
}

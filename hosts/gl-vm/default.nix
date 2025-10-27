{ lib, ... }: {

  imports = [
    ./hardware-configuration_apple.nix
    # ./hardware-configuration_qemu.nix

    ../common/global

    # ../common/optional/cosmic.nix
    # ../common/optional/hyprland.nix
    # ../common/optional/zfs.nix
  ];

  users.users.karl.openssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFiGTZKrOJF/E+CvHZ0ZGgFOAACNRU2MuDP2YdYjAM2v"
  ];
  # networking.firewall.allowedTCPPorts = [ 3000 ];

  # UTM Apple/QEMU guest integration - clipboard sharing/etc.
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  virtualisation.docker = {
    storageDriver = lib.mkForce "overlay2";
  }; # TODO, change after migrate to ZFS

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "6e63a55c";

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };
}

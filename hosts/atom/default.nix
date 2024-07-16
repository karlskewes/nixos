{ config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/global

    ../common/optional/zfs.nix
  ];

  # Define hostId for zfs pool machine 'binding'
  # :read !echo <hostname> | md5sum | cut -c1-8
  networking.hostId = "385d90d5";
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.openssh = {
    enable = true;
    settings = { PermitRootLogin = lib.mkForce "no"; };
  };

  virtualisation.libvirtd.enable = false;
  programs.dconf.enable = true;
}

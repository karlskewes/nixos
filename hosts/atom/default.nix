{ config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/global

    ../common/optional/zfs.nix
  ];

  environment.systemPackages = with pkgs; [ vim wget curl disko git netcat tcpdump ];

  services.tftpd.enable = true;
  services.tftpd.path = "/srv/tftp";

  # Define hostId for zfs pool machine 'binding'
  # :read !echo <hostname> | md5sum | cut -c1-8
  networking.hostId = "385d90d5";
  networking.firewall.allowedTCPPorts = [ 22 ];

  virtualisation.docker = { enable = false; };
  virtualisation.libvirtd.enable = false;
  programs.dconf.enable = true;
}

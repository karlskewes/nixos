{ config, lib, pkgs, ... }: {
  imports = [ ./base.nix ./i3.nix ./zfs.nix ];

  # Define hostId for zfs pool machine 'binding'
  # :read !echo <hostname> | md5sum | cut -c1-8
  networking.hostId = "b38b36dc";
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    vaapiVdpau
    libvdpau-va-gl
  ];

  # https://github.com/pi-hole/pi-hole
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:2023.05.2";
    extraOptions = [ "--hostname=pihole" ];
    ports = [ "53:53/udp" "53:53/tcp" "80:80/tcp" "443:443/tcp" ];
    environment = {
      TZ = "Pacific/Auckland";
      FTLCONF_REPLY_ADDR4 = "192.168.1.5"; # host machine IP
      WEB_PORT = "80";
      # VIRTUAL_HOST = "192.168.1.114";
      PIHOLE_DNS_ = "1.1.1.3;1.0.0.3";
      REV_SERVER = "true";
      REV_SERVER_DOMAIN = "home.arpa";
      REV_SERVER_TARGET = "192.168.1.1";
      REV_SERVER_CIDR = "192.168.1.0/24";
      # Podman (10/8) and Docker (172.16/12) differ to LAN 192.168/16 so we need
      # to tell Pihole to reply to  all source IP's (~similar to listen on all interfaces)
      DNSMASQ_LISTENING = "all";
    };
    volumes = [ "pihole:/etc/pihole" ];

  };

  # add any additional configuration here:
  # https://docs.pi-hole.net/core/pihole-command/
  systemd.services."docker-pihole".postStart = ''
    sleep 120s
    docker exec pihole pihole -w link.nzpost.co.nz
  '';

  # add any custom Docker networks like this:
  # system.activationScripts.mkVYOSnetwork = let
  #   docker = config.virtualisation.oci-containers.backend;
  #   dockerBin = "${pkgs.${docker}}/bin/${docker}";
  # in ''
  #   ${dockerBin} network inspect vyos >/dev/null 2>&1 || \
  #   ${dockerBin} network create vyos \
  #     -d macvlan \
  #     --subnet=192.168.1.0/24 \
  #     --ip-range=192.168.1.128/24 \
  #     --gateway=192.168.1.1 \
  #     -o parent=${hostNic}
  # '';

  virtualisation.libvirtd.enable = false;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ cdrkit virt-manager ];
}

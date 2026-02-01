{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules

    ../modules/cosmic.nix
    ../modules/zfs.nix
  ];

  zfsBootUnlock = {
    enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew hello@karlskewes.com"
    ];
    interfaces = [ "e1000e" ];
  };

  networking.firewall.allowedTCPPorts = [
    3000 # basketball subs subbers,gosubs
    8080 # basketball subs subbers,gosubs
  ];

  # Define hostId for zfs pool machine 'binding'
  # :read !echo <hostname> | md5sum | cut -c1-8
  networking.hostId = "b38b36dc";
  networking.interfaces.enp0s31f6.useDHCP = true;
  # networking.interfaces.wlp1s0.useDHCP = true;

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--advertise-exit-node" ];
  };
  # https://tailscale.com/kb/1320/performance-best-practices#ethtool-configuration
  networking.localCommands = ''
    ${pkgs.ethtool}/bin/ethtool -K enp0s31f6 rx off tx off
  '';

  # https://discourse.nixos.org/t/znc-config-without-putting-password-hash-in-configuration-nix/14236/3
  # cyrusauth module talks to saslauthd, default auth mechanism is PAM
  services.saslauthd.enable = true;

  environment.etc = {
    # need to add a PAM service config, cyrusauth identifies itself as "znc"
    # very standard config, copied from others in /etc/pam.d
    # just checks that you have a valid account/password
    "pam.d/znc" = {
      source = pkgs.writeText "znc.pam" ''
        # Account management.
        account required pam_unix.so

        # Authentication management.
        auth sufficient pam_unix.so likeauth try_first_pass
        auth required pam_deny.so

        # Password management.
        password sufficient pam_unix.so nullok sha512

        # Session management.
        session required pam_env.so conffile=/etc/pam/environment readenv=0
        session required pam_unix.so
      '';
    };
  };

  # znc service config has some hardening options that otherwise block
  # interaction with saslauthd's unix socket
  systemd.services.znc.serviceConfig.RestrictAddressFamilies = [ "AF_UNIX" ];

  services.znc = {
    enable = true;
    mutable = false;
    openFirewall = true;
    useLegacyConfig = false;
    config = {
      LoadModule = [
        "adminlog"
        "cyrusauth saslauthd"
        "webadmin"
      ];
      Listener.l = {
        Port = 16667;
        AllowIRC = true;
        AllowWeb = true;
        SSL = false;
      };
      User.karl = {
        Admin = true;
        # fake hash, auth against this will always fail, user can only login via SASL
        # znc compains if you have no Pass
        Pass = "md5#::#::#";
        Nick = "k70";
        AltNick = "k70_";
        Ident = "karl";
        ChanBufferSize = 1000;
        QuitMsg = "gone";
        Network.oftc = {
          Server = "irc.oftc.net +6697";
          LoadModule = [
            "keepnick"
            "simple_away"
          ];
          Chan = {
            "#asahi" = { };
            "#asahi-alt" = { };
            "#asahi-dev" = { };
            "#asahi-gpu" = { };
            "#asahi-re" = { };
          };
        };
      };
    };
  };

  # https://github.com/pi-hole/pi-hole
  # https://github.com/pi-hole/docker-pi-hole
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:2025.11.0";
    extraOptions = [ "--hostname=pihole" ];
    ports = [
      "53:53/udp"
      "53:53/tcp"
      "80:80/tcp"
      "443:443/tcp"
    ];
    environment = {
      TZ = "Australia/Brisbane";
      FTLCONF_LOCAL_IPV4 = "192.168.1.5"; # host machine IP
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
    docker exec pihole pihole -w click.discord.com
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
  environment.systemPackages = with pkgs; [
    cdrkit
    ethtool
    virt-manager
  ];
}

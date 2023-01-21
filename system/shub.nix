{ config, pkgs, lib, ... }:

let
  guests = {
    # https://docs.vyos.io/en/latest/installation/virtual/libvirt.html
    # vyos = {
    #   memory = "512"; # MB
    #   diskSize = "5"; # GB
    #   image = "images/vyos.qcow2";
    #   mac = "52:54:00:00:00:32";
    #   ip = "192.168.1.32"; # Ignored, only for personal reference
    # };
  };
  hostNic = "enp0s31f6";

in {
  # Define hostId for zfs pool machine 'binding'
  # :read !echo <hostname> | md5sum | cut -c1-8
  networking.hostId = "b38b36dc";
  networking.networkmanager.enable = true;
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    vaapiVdpau
    libvdpau-va-gl
  ];
  # Need full for bluetooth support
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # https://github.com/pi-hole/pi-hole
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:2023.01.6";
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
  # systemd.services."docker-pihole".postStart = ''
  #   sleep 300s
  #   podman exec pihole pihole -g
  # '';

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

  # Create a libvirtd storage pool if it doesn't exist
  # system.activationScripts.mkLibvirtPool =
  #   let virshBin = "${pkgs.${libvirtd}}/bin/virsh";
  #   in ''
  #     ${virshBin} pool-list | grep 'default' >/dev/null 2>&1 || \
  #     ${virshBin} pool-list
  #   '';

  # $ sudo virsh pool-dumpxml default
  # <pool type='dir'>
  #   <name>default</name>
  #   <uuid>3edfd573-a5ce-4a82-8c00-70da7d1a524e</uuid>
  #   <capacity unit='bytes'>104159641600</capacity>
  #   <allocation unit='bytes'>1169948672</allocation>
  #   <available unit='bytes'>102989692928</available>
  #   <source>
  #   </source>
  #   <target>
  #     <path>/var/lib/libvirt/images</path>
  #     <permissions>
  #       <mode>0711</mode>
  #       <owner>0</owner>
  #       <group>0</group>
  #     </permissions>
  #   </target>
  # </pool>

  systemd.services = lib.mapAttrs' (name: guest:
    lib.nameValuePair "libvirtd-guest-${name}" {
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
      script = let
        domXML = pkgs.writeText "libvirt-guest-${name}.xml" ''
          <domain type="kvm">
            <name>${name}</name>
            <uuid>UUID</uuid>
            <os>
              <type>hvm</type>
            </os>
            <memory unit="MiB">${guest.memory}</memory>
            <devices>
              <disk type="file" device="disk">
                <driver name="qemu" type="qcow2"/>
                <source file="/var/lib/libvirt/${guest.image}"/>
                <target dev="vda" bus="virtio"/>
              </disk>
              <disk type="file" device="disk">
                <driver name="qemu" type="raw"/>
                <source file="/var/lib/libvirt/images/cidata.iso"/>
                <target dev="hda" bus="ide"/>
              </disk>
              <graphics type="spice" autoport="yes"/>
              <input type="keyboard" bus="usb"/>
              <interface type="direct">
                <source dev="${hostNic}" mode="bridge"/>
                <mac address="${guest.mac}"/>
                <model type="virtio"/>
              </interface>
            </devices>
            <features>
              <acpi/>
            </features>
          </domain>
        '';
        volXML = pkgs.writeText "libvirt-guest-${name}-vol.xml" ''
          <volume>
            <name>${name}-extra.qcow2</name>
            <capacity unit="GiB">${guest.diskSize}</capacity>
            <allocation>0</allocation>
            <target>
              <format type="qcow2"/>
            </target>
          </volume>
        '';

      in ''
        # ${pkgs.libvirt}/bin/virsh vol-info --pool default --vol ${name}-extra.qcow2 >/dev/null 2>&1 || \
        # ${pkgs.libvirt}/bin/virsh vol-create --pool default --file '${volXML}'

        uuid="$(${pkgs.libvirt}/bin/virsh domuuid '${name}' || true)"
        ${pkgs.libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${domXML}')
        ${pkgs.libvirt}/bin/virsh start '${name}'
      '';
      preStop = ''
        ${pkgs.libvirt}/bin/virsh shutdown '${name}'
        let "timeout = $(date +%s) + 10"
        while [ "$(${pkgs.libvirt}/bin/virsh list --name | grep --count '^${name}$')" -gt 0 ]; do
          if [ "$(date +%s)" -ge "$timeout" ]; then
            # Meh, we warned it...
            ${pkgs.libvirt}/bin/virsh destroy '${name}'
          else
            # The machine is still running, let's give it some time to shut down
            sleep 0.5
          fi
        done
      '';
    }) guests;
}

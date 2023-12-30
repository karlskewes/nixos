# TODO:
# - validate guests as is
# - generate ${guest}-cidata.iso ?
# - generate qcow2 image from img ?
# - ensure images in right location ?
# - confirm storage pool creation not required, fresh host install?
# - network bridge creation?
# - network bridge or NAT option
# - confirm disk volume setup
#   - base-image.qcow2 for sharing by multiple VM's
#   - ${guest}-extra.qcow2 per VM

# Example VM guests configuration:
# guests = {
#   ubuntu-0 = {
#     memory = "4096"; # MB
#     diskSize = "10"; # GB
#     image = "images/ubuntu-0.qcow2"; # /var/lib/libvirt/{$guest.image}
#     # cidata.iso - ${name}-cidata.is
#     mac = "52:54:00:00:00:32";
#     ip = "192.168.1.32"; # Ignored, only for personal reference
#   };
#   https://docs.vyos.io/en/latest/installation/virtual/libvirt.html
#   vyos = {
#     memory = "512"; # MB
#     diskSize = "5"; # GB
#     image = "images/vyos.qcow2";
#     mac = "52:54:00:00:00:32";
#     ip = "192.168.1.32"; # Ignored, only for personal reference
#   };
# };

{ config, lib, pkgs, currentUsers, hostNIC, guests ? { }, ... }: {
  nixpkgs.config = {
    # system user
    # for each user in currentUsers, generate users.user.${user} config.
    users.users = builtins.foldl'
      (
        acc: user:
          acc // {
            ${user} = {
              extraGroups = [
                "libvirtd"
              ];
            };
          }
      )
      { }
      (currentUsers);


    virtualisation.libvirtd.enable = true;
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

    systemd.services = lib.mapAttrs'
      (name: guest:
        lib.nameValuePair "libvirtd-guest-${name}" {
          after = [ "libvirtd.service" ];
          requires = [ "libvirtd.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = "yes";
          };
          script =
            let
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
                      <source file="/var/lib/libvirt/images/${name}-cidata.iso"/>
                      <target dev="hda" bus="ide"/>
                    </disk>
                    <graphics type="spice" autoport="yes"/>
                    <input type="keyboard" bus="usb"/>
                    <interface type="direct">
                      <source dev="${hostNIC}" mode="bridge"/>
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

            in
            ''
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
        })
      guests;
  };
}

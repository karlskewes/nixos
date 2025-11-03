# TODO: reformat params and make this a lib or similar.
let
  machine = "gl-vm";
  # Find base disk ID `read !ls /dev/disk/by-id/*`
  # For UTMAPP Apple VM's this is parts 1-4 of the backing file <1>-<2>-<3>-<4>-<5>.img
  disk = "/dev/disk/by-id/virtio-0E6E853EAFC44A4ABA03";
  disk_friendly = "virtio-one";
in {
  disko.devices = {
    disk = {
      "${disk_friendly}" = {
        type = "disk";
        device = "${disk}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true; # resume from hiberation from this device
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "${machine}";
              };
            };
          };
        };
      };
    };
    zpool = {
      "${machine}" = {
        type = "zpool";
        mode = "";
        mountpoint = null;
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          "com.sun:auto-snapshot" = "false";
          compression = "zstd";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          # comment keylocation to be prompted during disko run
          # keylocation = "file:///tmp/secret.key";
          keylocation = "prompt";

        };
        # mountpoint = "/";
        postCreateHook = ''
          zfs set keylocation="prompt" "${machine}";
        '';

        datasets = {
          reserved = {
            type = "zfs_fs";
            mountpoint = null;
            options."refreservation" = "1G";
          };
          # snapshots ENABLED
          snap = {
            type = "zfs_fs";
            options.canmount = "off";
          };
          "snap/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = ''
              zfs snapshot ${machine}/snap/root@blank
            '';
          };
          # snapshots DISABLED
          nosnap = {
            type = "zfs_fs";
            options.canmount = "off";
            options."com.sun:auto-snapshot" = "false";
          };
          "nosnap/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          "nosnap/containers" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/containers";
            options.mountpoint = "legacy";
          };
          "nosnap/docker" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/docker";
            options.mountpoint = "legacy";
          };
          "nosnap/libvirt" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/libvirt";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}

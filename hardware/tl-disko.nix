# TODO: reformat params and make this a lib or similar.
let
  machine = "tl";
  # Find base disk ID `read !ls /dev/disk/by-id/*`
  disk = "/dev/disk/by-id/nvme-Micron_MTFDKBA512TFK_222340E5EFF6";
  disk_friendly = "m2-ssd";
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
              size = "4G";
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
                pool = "rpool-${machine}";
              };
            };
          };
        };
      };
    };
    zpool = {
      "rpool-${machine}" = {
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
          # keylocation = "file:///tmp/secret.key";
          keylocation = "prompt";

        };
        # mountpoint = "/";
        postCreateHook = ''
          zfs set keylocation="prompt" "rpool-${machine}";
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
              zfs snapshot rpool-${machine}/snap/root@blank
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

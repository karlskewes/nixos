let
  machine = "example_machine";
  disk = "example_disk";
in {
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = "${disk}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1024";
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
        mode = "mirror";
        rootFsOptions = {
          acltype = "posixacl";
          ashift = "12";
          autotrim = "on";
          canmount = "off";
          "com.sun:auto-snapshot" = "false";
          compression = "zstd";
          dnodesize = "auto";
          mountpoint = "none";
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
            mountpoint = "none";
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

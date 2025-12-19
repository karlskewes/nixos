# TODO: reformat params and make this a lib or similar.
let
  # Find base disk ID `read !ls /dev/disk/by-id/*`
  disk = "/dev/disk/by-id/nvme-APPLE_SSD_AP1024Q_0ba0106320e4fa15";
  disk_friendly = "nvme";
in {
  disko.devices = {
    disk = {
      "${disk_friendly}" = {
        destroy = false;
        type = "disk";
        device = "${disk}";

        content = {
          type = "gpt";
          partitions = {
            iBootSystemContainer = {
              label = "iBootSystemContainer";
              priority = 1;
              type = "AF0B";
              uuid = "0fb90dd4-6e41-4d38-b46b-99d0602a27a4";
            };

            Container = {
              label = "Container";
              priority = 2;
              type = "AF0A";
              uuid = "7d772c1c-fdb4-4004-813b-3b51dfd6d5f9";
            };

            NixOSContainer = {
              priority = 3;
              type = "AF0A";
              uuid = "7c3182d7-a3dc-4612-88c8-22a329aaaa75";
            };

            ESP = {
              # ls /dev/disk/by-partuuid/
              uuid = "6a839a09-3d75-40a8-8e10-f4e0160e1d88";
              priority = 4;
              # size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            RecoveryOSContainer = {
              label = "RecoveryOSContainer";
              priority = 5;
              type = "AF0C";
              uuid = "cf976249-a4c8-4ab4-a5a6-1728c887916b";
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # disable settings.keyFile if you want to use interactive password entry
                # passwordFile = "/tmp/secret.key"; # Interactive
                # settings = {
                #   allowDiscards = true;
                #   keyFile = "/tmp/secret.key";
                # };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                extraFormatArgs = [ "--pbkdf argon2id" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "8G";
                    };
                  };
                };
              };
            };

          };
        };
      };
    };
  };
}

# TODO: reformat params and make this a lib or similar.
let
  # Find base disk ID `read !ls /dev/disk/by-id/*`
  disk = "/dev/disk/by-id/nvme-APPLE_SSD_AP0512Z_0ba01f0c22591a20";
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
              uuid = "ca58ee0f-d4de-4e27-a809-ac1c42d6fc24";
            };

            Container = {
              label = "Container";
              priority = 2;
              type = "AF0A";
              uuid = "ec531500-04e8-4e3c-969d-f6f106b4e653";
            };

            NixOSContainer = {
              priority = 3;
              type = "AF0A";
              uuid = "0113ae75-de9c-4165-95db-f2c8a297c2d6";
            };

            ESP = {
              # ls /dev/disk/by-partuuid/
              uuid = "68ec9ab1-1413-45bb-9553-e14aca305696";
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
              uuid = "fd9e528c-fe2d-49e9-afcd-c9cc9a0c65d2";
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

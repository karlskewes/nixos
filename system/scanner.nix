{ config
, pkgs
, currentUsers
, currentSystem
, ...
}:

{
  # system user
  # for each user in currentUsers, generate users.user.${user} config.
  users.users = builtins.foldl'
    (
      acc: user:
        acc // {
          ${user} = {
            extraGroups = [
              "scanner" # scanning
              "lp" # scanning
            ];
          };
        }
    )
    { }
    (currentUsers);

  environment.systemPackages = with pkgs; [ simple-scan ];

  hardware.sane = {
    enable = {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";

    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "MFC-L2713DW";
          ip = "192.168.1.104";
          # nodename = "BRW1CBFC0F36D0B";
        };
      };
    };
    # brscan5 = { enable = true; };
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };

}

{ config
, pkgs
, currentRevision
, currentUser
, currentSystem
, currentSystemName
, ...
}:

{
  # system user
  users.users.${currentUser} = {
    extraGroups = [
      "scanner" # scanning
      "lp" # scanning
    ];
  };

  environment.systemPackages = with pkgs; [ simple-scan ];

  hardware.sane = {
    enable = true;
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

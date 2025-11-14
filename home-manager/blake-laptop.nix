({ config, pkgs, ... }: {
  # TODO: multiple users
  imports = [
    ./user-karl.nix

    ./modules

    ./modules/i3.nix
  ];

  custom.firefox = {
    enable = true;
    users = [ "blake" "karl" ];
  };

  home.packages = with pkgs; [ ];
  xresources.properties = { "Xft.dpi" = "96"; };
})

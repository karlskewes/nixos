({ config, pkgs, ... }: {
  # TODO: multiple users
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/i3.nix
  ];

  desktop.firefox = {
    enable = true;
    users = [ "blake" "karl" ];
  };

  home.packages = with pkgs; [ ];
  xresources.properties = { "Xft.dpi" = "96"; };
})

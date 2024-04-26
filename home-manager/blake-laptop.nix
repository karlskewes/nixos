({ config, pkgs, ... }: {
  # TODO: multiple users
  imports = [ ./user-karl.nix ./xwindows.nix ];
  home.packages = with pkgs; [ ];
  xresources.properties = { "Xft.dpi" = "96"; };
})

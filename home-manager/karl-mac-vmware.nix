{ config, pkgs, ... }:

{
  imports = [ ./dev.nix ./xwindows.nix ];

  # Make terminal not tiny on HiDPI screens
  xresources.properties = { "Xft.dpi" = "220"; };

  # Make cursor not tiny on HiDPI screens
  xsession = {
    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 128;
    };
  };
}

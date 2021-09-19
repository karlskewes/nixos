{ config, pkgs, ... }:

{
  imports = [ ./dev.nix ./xwindows.nix ];

  programs.i3status = {
    modules = {
      # VM so these aren't available
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

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

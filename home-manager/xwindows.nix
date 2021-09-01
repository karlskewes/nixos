# X Windows additional configuration dependent on home-manager
{ config, pkgs, ... }:

{
  # required for google-chrome
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    google-chrome
    pavucontrol
    xclip
  ];

  programs.i3status = {
    enable = true;

    modules = {
      # VM so these aren't available
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  # Make terminal not tiny on HiDPI screens
  xresources.properties = { "Xft.dpi" = "220"; };
  # Make cursor not tiny on HiDPI screens
  xsession.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
  };
}

# X Windows additional configuration dependent on home-manager
{ config, pkgs, ... }:

{
  # required for google-chrome
  nixpkgs.config = { allowUnfree = true; };

  home.packages = with pkgs; [
    google-chrome
    libnotify # required by dunst
    pavucontrol
    qalculate-gtk
    xclip

    # move to programs.rofi.plugins after 21.05
    rofi-calc
    rofi-emoji
    rofi-power-menu
  ];

  programs.i3status = {
    enable = true;

    modules = {
      # VM so these aren't available
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  programs.rofi = {
    enable = true;
    font = "Monospace 14";
    # not in 21.05
    # plugins = with pkgs; [
    #   rofi-calc
    #   rofi-emoji
    #   rofi-power-menu
    # ];
  };

  services.dunst = { enable = true; };

  services.flameshot = { enable = true; };

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

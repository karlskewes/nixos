# Sway window manager configuration.
{ config, lib, pkgs, ... }: {

  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  programs.swaylock.enable = true;

  programs.rofi = { package = pkgs.rofi-wayland; };

  programs.i3status.enable = false;

  programs.waybar = { enable = true; };

  services.swayidle.enable = true;
  services.swayosd.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty";
      startup = [ { command = "kitty"; } { command = "firefox"; } ];
    };
  };

}

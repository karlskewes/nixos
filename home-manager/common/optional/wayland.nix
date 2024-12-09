# Sway window manager configuration.
{ config, lib, pkgs, ... }: {

  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  home.packages = with pkgs; [
    wl-clipboard

    grimblast # screenshot combo grim, slurp, etc
    swappy # screenshot annotation
  ];

  programs.bash.shellAliases = {
    # Copy Paste to clipboard.
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  programs.rofi = { package = pkgs.rofi-wayland; };
  programs.waybar = { enable = true; };

  services.playerctld.enable = true;
  services.swayosd.enable = true;
  services.wlsunset = {
    enable = true;
    sunrise = "06:00";
    sunset = "19:00";
  };
}

{ config, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # setup windowing environment
  services.xserver = { displayManager = { defaultSession = "hyprland"; }; };
}

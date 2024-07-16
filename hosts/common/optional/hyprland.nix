{ config, pkgs, ... }:

{
  imports = [ ./windowing.nix ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.defaultSession = "hyprland";
}

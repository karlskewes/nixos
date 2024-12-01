{ config, pkgs, ... }:

{
  imports = [ ./wayland.nix ];

  programs.sway = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.defaultSession = "sway";
}

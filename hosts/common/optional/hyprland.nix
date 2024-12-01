{ config, pkgs, ... }:

{
  imports = [ ./windowing.nix ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # security.pam.services.hyprlock = { };
  security.pam.services.hyprland.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.dbus.enable = true;
  services.displayManager = {
    sddm.enable = true;
    sddm.enableHidpi = true;
    sddm.wayland.enable = true;
  };

  services.displayManager.defaultSession = "hyprland-uwsm";
}

{ config, pkgs, ... }:

{
  imports = [ ./windowing.nix ];

  services.dbus.enable = true;

  # services.displayManager.defaultSession = "sway"; # or as required.

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    # enable touchpad on laptops
    xkb.options =
      "caps:escape"; # make caps lock function as escape for easier vim

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "scale";
    };
  };

  services.displayManager = {
    sddm.enable = true;
    sddm.enableHidpi = true;
    sddm.wayland.enable = true;
  };
}

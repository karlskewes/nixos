{ config, pkgs, ... }:

{
  imports = [ ./windowing.nix ];

  services.dbus.enable = true;

  # services.displayManager.defaultSession = "sway"; # or as required.

  services.xserver = {
    enable = true;
    layout = "us";
    # enable touchpad on laptops
    xkbOptions =
      "caps:escape"; # make caps lock function as escape for easier vim

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "scale";
    };

    displayManager = {
      sddm.enable = true;
      sddm.enableHidpi = true;
      sddm.wayland.enable = true;
    };

  };
}

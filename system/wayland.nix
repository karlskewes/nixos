{ config, pkgs, ... }:

{
  imports = [ ./windowing.nix ];

  services.dbus.enable = true;

  # setup windowing environment
  services.xserver = {
    enable = true;
    layout = "us";
    # enable touchpad on laptops
    libinput.enable = true;
    xkbOptions =
      "caps:escape"; # make caps lock function as escape for easier vim

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "scale";
    };

    displayManager = {
      # defaultSession = "sway";
      sddm.enable = true;
      sddm.enableHidpi = true;
      sddm.wayland.enable = true;
    };

  };
}

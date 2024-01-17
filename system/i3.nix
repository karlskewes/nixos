{ config, lib, pkgs, ... }:

{
  imports = [ ./windowing.nix ];

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
      defaultSession = "none+i3";
      lightdm.enable = true;
      sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xset r rate 200 40
      '';
    };

    windowManager = { i3.enable = true; };
  };
}
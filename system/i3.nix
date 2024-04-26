{ config, lib, pkgs, ... }:

{
  imports = [ ./windowing.nix ];

  services.displayManager.defaultSession = "none+i3";

  services.xserver = {
    enable = true;
    # enable touchpad on laptops
    libinput.enable = true;
    xkb.layout = "us";
    xkb.options =
      "caps:escape"; # make caps lock function as escape for easier vim

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "scale";
    };

    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xset r rate 200 40
      '';
    };

    windowManager = { i3.enable = true; };
  };
}

{ config, pkgs, ... }:

{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # setup windowing environment
  services.xserver = {
    enable = true;
    layout = "us";

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

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # Need full for bluetooth support
    # package = pkgs.pulseaudioFull;
    support32Bit = true;
  };
}

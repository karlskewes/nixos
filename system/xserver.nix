{ config, pkgs, ... }:

{
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  # doesn't exist?
  # hardware.opengl.driSupport32bit = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # setup windowing environment
  services.gnome3.gnome-keyring.enable = true;
  services.gnome3.seahorse.enable = true;
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

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # Need full for bluetooth support
    # package = pkgs.pulseaudioFull;
    support32Bit = true;
  };
}

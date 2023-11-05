{ config, pkgs, ... }:

{
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  # doesn't exist?
  # hardware.opengl.driSupport32bit = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # setup windowing environment
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
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
  sound.enable = false; # Using pipewire below
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}

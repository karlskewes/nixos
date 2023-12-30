{ config, pkgs, ... }:

{
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  # doesn't exist?
  # hardware.opengl.driSupport32bit = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

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
      defaultSession = "hyprland";
      sddm.enable = true;
      sddm.enableHidpi = true;
      sddm.wayland.enable = true;
    };

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

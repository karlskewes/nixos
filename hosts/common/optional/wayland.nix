{ pkgs, lib, ... }:

{
  imports = [ ./windowing.nix ];

  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [ greetd.tuigreet ];

  services.blueman.enable = true; # bluetooth

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = lib.mkDefault
          "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

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

  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}

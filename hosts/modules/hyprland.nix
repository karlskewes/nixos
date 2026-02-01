{ pkgs, ... }:

{
  imports = [ ./windowing.nix ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true; # https://wiki.hyprland.org/Useful-Utilities/Systemd-start/
  };

  # security.pam.services.hyprlock = { };
  security.pam.services.hyprland.enableGnomeKeyring = true;

  services.blueman.enable = true; # bluetooth

  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [ greetd.tuigreet ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };
  };

  services.upower.enable = true;

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

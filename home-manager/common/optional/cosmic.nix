{ pkgs, lib, ... }: {
  imports = [ ./desktop.nix ];

  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  home.pointerCursor = {
    gtk.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = lib.mkDefault 24;
  };

  programs.bash.shellAliases = {
    # Copy Paste to clipboard.
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  home.packages = with pkgs; [
    wl-clipboard

    ferrishot
    satty # screenshot annotation - use with satty --filename X.png --output-filename Y.png

    cosmic-ext-calculator
    xdg-desktop-portal-gtk
  ];

  xdg.portal.extraPortals =
    [ pkgs.xdg-desktop-portal-cosmic pkgs.xdg-desktop-portal-gtk ];
  # Must start after keyring to be effective...
  # xdg.configFile."autostart/gnome-keyring-daemon.desktop".text = ''
  #   [Desktop Entry]
  #   Version=1.0
  #   Name=gnome-keyring-daemon
  #   GenericName=Gnome Keyring Daemon
  #   Comment=Gnome Keyring Daemon
  #   Exec=/run/wrappers/bin/gnome-keyring-daemon --start --daemonize
  #   Icon=gnome
  #   Terminal=false
  #   Type=Application
  #   Categories=Utility;
  #   StartupNotify=true
  #   Hidden=true
  #   X-GNOME-Autostart-enabled=true
  # '';

}

{ pkgs, ... }: {
  imports = [ ./desktop.nix ./wayland.nix ];

  home.packages = with pkgs; [ cosmic-ext-calculator ];

  home.pointerCursor = { size = 24; };

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

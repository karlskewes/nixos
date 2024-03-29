# Sway window manager configuration.
{ config, lib, pkgs, ... }: {
  imports = [ ./wayland.nix ];

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty";
      startup = [
        # handled by i3.conf
        # { command = "kitty"; }
        # { command = "firefox"; }
      ];
    };
  };
}

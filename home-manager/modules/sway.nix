{ pkgs, ... }: {
  imports = [ ./desktop.nix ./wayland.nix ];

  programs.swaylock = {
    enable = true;
    settings = { color = "404040"; };
  };

  services.swayidle.enable = true;

  services.swayosd = { enable = true; };

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

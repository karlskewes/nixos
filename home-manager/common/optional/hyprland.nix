# X Windows additional configuration dependent on home-manager
{ config, lib, pkgs, ... }: {
  imports = [ ./desktop.nix ./wayland.nix ];

  programs.swaylock = {
    enable = true;
    settings = { color = "404040"; };
  };

  # TODO: figure out how to get it to work.
  programs.hyprlock = {
    enable = false;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 300;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [{
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }];

      input-field = [{
        size = "200, 50";
        position = "0, -80";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        font_color = "rgb(202, 211, 245)";
        inner_color = "rgb(91, 96, 120)";
        outer_color = "rgb(24, 25, 38)";
        outline_thickness = 5;
        placeholder_text =
          ''<span foreground="##cad3f5">Password...</sfalsepan>'';
        shadow_passes = 2;
      }];
    };
  };

  programs.waybar = {
    # style = '' ''; # Default is fine. #workspaces button.active.color = green; be nice.
    settings = {
      mainBar = {
        layer = "top";
        modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "hyprland/language"
          "battery"
          "clock"
          "tray"
        ];
        "hyprland/window" = { max-length = 50; };
        "hyprland/workspaces" = {
          active-only = false;
          format = "{icon}: {windows}";
          format-window-separator = "  |  ";
          window-rewrite-default = "";
          window-rewrite = {
            # https://www.nerdfonts.com/cheat-sheet
            "title<.*youtube.*>" = "   Youtube";
            "class<firefox>" = "󰈹  Firefox";
            "class<kitty>" = "  Terminal";
            "class<Slack>" = "󰒱  Slack";
          };
        };
        battery = {
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        clock = {
          format = "{:%a, %d. %b  %H:%M}";
          "tooltip-format" = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };
        "cpu" = {
          "format" = "{usage}% ";
          "tooltip" = false;
        };
        "memory" = { "format" = "{}% "; };
        "temperature" = {
          "critical-threshold" = 80;
          "format" = "{temperatureC}°C {icon}";
          "format-icons" = [ "" "" "" ];
        };
        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "";
            "deactivated" = "";
          };
        };
        "network" = {
          # // "interface" = "wlp2*"; // (Optional) To force the use of this interface
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr}/{cidr} ";
          "tooltip-format" = "{ifname} via {gwaddr} ";
          "format-linked" = "{ifname} (No IP) ";
          "format-disconnected" = "Disconnected ⚠";
          "format-alt" = "{ifname}: {ipaddr}/{cidr}";
        };
        "pulseaudio" = {
          # // "scroll-step" = 1; // %, can be a float
          "format" = "{volume}% {icon}  {format_source}";
          "format-bluetooth" = "{volume}% {icon}  {format_source}";
          "format-bluetooth-muted" = " {icon}  {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" "" ];
          };
          "on-click" = "pavucontrol";
        };
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "swaylock"; # TODO hyprlock
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "swaylock"; # TODO hyprlock
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ../../../dotfiles/hyprland.conf;
    settings = {
      exec-once = [
        # start gnome-keyring for ssh to replace gpg agent
        "/run/wrappers/bin/gnome-keyring-daemon --start --daemonize"
        "waybar"
        "[workspace 2 silent] firefox"
        "kitty" # workspace 1
      ];
    };
  };
}

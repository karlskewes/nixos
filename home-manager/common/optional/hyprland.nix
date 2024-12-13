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
    style = ''
            * {
          border: none;
          border-radius: 0;
          font-family: Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(30, 33, 42, 1);
          color: white;
      }

      tooltip {
        background: rgba(30, 33, 42, 0.8);
        border: 1px solid rgba(100, 114, 125, 0.5);
      }
      tooltip label {
        color: white;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: white;
          border-bottom: 3px solid transparent;
      }

      #workspaces button.active {
        color: green;
      }

      #workspaces button.focused {
          background: #64727D;
          border-bottom: 3px solid white;
      }

      #mode,
      #tray,
      #clock,
      #battery,
      #temperature,
      #disk,
      #memory,
      #cpu,
      #network,
      #pulseaudio {
          padding: 0 10px;
      }

      #mode {
      }

      #clock {
      }

      #battery {
      }

      #battery.charging {
          color: white;
          background-color: #26A65B;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: black;
          }
      }

      #battery.warning:not(.charging) {
          background: #f53c3c;
          color: white;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "disk"
          "temperature"
          # "hyprland/language" # enable if/when JP input
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
          format = "{icon}  {capacity}%";
          format-icons = [ "" "" "" "" "" ];
        };
        clock = {
          interval = 5;
          format = "{:%a, %d. %b  %H:%M:%S}";
          "tooltip-format" = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
        };
        "cpu" = {
          "format" = " {usage}%";
          "tooltip-format" = "L: {load}";
        };
        "disk" = {
          "format" = "󰋊 {percentage_used}%";
          "tooltip-format" = "D: {used} / {total}";
        };
        "memory" = {
          "format" = " {}%";
          "tooltip-format" =
            "{used:0.1f} G of {total:0.1f} G. Swap: {swapPercentage}%";
        };
        "temperature" = {
          "critical-threshold" = 80;
          "format" = "{icon} {temperatureC}°C";
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
          "format-wifi" = "  {essid} ({signalStrength}%)";
          "format-ethernet" = "󰈀 {ipaddr}/{cidr}";
          "tooltip-format" = "{ifname} via {gwaddr}";
          "format-linked" = "{ifname} (No IP)";
          "format-disconnected" = "⚠ Disconnected";
          "format-alt" = "{ifname}: {ipaddr}/{cidr}";
        };
        "pulseaudio" = {
          # // "scroll-step" = 1; // %, can be a float
          "format" = "{icon} {volume}%  {format_source}";
          "format-bluetooth" = "{icon} {volume}%  {format_source}";
          "format-bluetooth-muted" = "{icon}   {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = " {volume}%";
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

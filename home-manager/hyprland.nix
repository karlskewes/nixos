# X Windows additional configuration dependent on home-manager
{ config, lib, pkgs, ... }: {
  imports = [ ./wayland.nix ];

  programs.waybar = {
    enable = true;
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
          "format" = "{volume}% {icon} {format_source}";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
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

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ../dotfiles/hyprland.conf;
  };
}

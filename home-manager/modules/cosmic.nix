{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./desktop.nix ];

  options.custom.cosmic = {
    screen = lib.mkOption {
      description = "default screen for pinned workspaces";
      type = lib.types.str;
      default = "eDP-1";
    };
  };

  config = {
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    home.pointerCursor = {
      gtk.enable = true;
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = lib.mkDefault 24;
    };

    home.packages = with pkgs; [
      wl-clipboard

      ferrishot
      satty # screenshot annotation - use with satty --filename X.png --output-filename Y.png

      cosmic-ext-calculator
      xdg-desktop-portal-gtk
    ];

    programs.bash.shellAliases = {
      # Copy Paste to clipboard.
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
    };

    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };

    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-cosmic
      pkgs.xdg-desktop-portal-gtk
    ];

    home.file.".config/cosmic/com.system76.CosmicComp/v1/autotile".text = "true";
    home.file.".config/cosmic/com.system76.CosmicComp/v1/autotile_behavior".text = "PerWorkspace";
    home.file.".config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions".text = ''
      {
          Terminal: "kitty",
      }
    '';
    # TODO: remove _nixos
    home.file.".config/cosmic/com.system76.CosmicSettings.WindowRules/v1/workspace_assignment_custom_nixos".text =
      ''
        [
          (
            enabled: true,
            appid: ".*",
            title: "kitty",
            workspace_id: "terminal",
          ),
          (
            enabled: true,
            appid: ".*",
            title: "firefox",
            workspace_id: "browser",
          ),
          (
            enabled: true,
            appid: ".*",
            title: "Halloy",
            workspace_id: "chat"
          )
        ]
      '';

    # TODO: remove _nixos
    home.file.".config/cosmic/com.system76.CosmicComp/v1/pinned_workspaces_nixos".text = ''
      [
        (
          output: (
              name: "${config.custom.cosmic.screen}",
              edid: None,
          ),
          tiling_enabled: true,
          id: Some("terminal"),
        ),
        (
          output: (
              name: "${config.custom.cosmic.screen}",
              edid: None,
          ),
          tiling_enabled: true,
          id: Some("browser"),
        ),
        (
          output: (
              name: "${config.custom.cosmic.screen}",
              edid: None,
          ),
          tiling_enabled: true,
          id: Some("chat"),
        ),
      ]
    '';

  };
}

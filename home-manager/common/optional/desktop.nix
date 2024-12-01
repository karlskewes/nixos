# X Windows additional configuration dependent on home-manager
{ config, lib, pkgs, currentSystem, ... }: {
  xdg.configFile."discord/settings.json".text = ''
    {
      "BACKGROUND_COLOR": "#202225",
      "SKIP_HOST_UPDATE": true
    }
  '';

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.hack

    ente-auth

    vlc
    gwenview # image viewer & editor (crop, resize)
    helvum # pipewire patch bay gui
    iwgtk # iwd gui
    libnotify # required by dunst
    pavucontrol # pulseaudio gui
    qalculate-gtk # calculator
    rofi-power-menu # doesn't work as extra package
  ];

  programs.firefox = {
    enable = true;
    policies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
    };
    # TODO: might not be required as login with Mozilla Account.
    # profiles = {
    #   default = {
    #     id = 0;
    #     name = "default";
    #     isDefault = true;
    #     settings = lib.mkMerge [{
    #       # "extensions.pocket.enabled" = false; # Still required if policies set?
    #     }];
    #   };
    # };
  };

  programs.kitty = {
    enable = true;
    font.name = "Hack Nerd Font";
    settings = { enable_audio_bell = false; };
    extraConfig = ''
      map ctrl+shift+enter new_window_with_cwd
    '';
  };

  programs.rofi = {
    package = lib.mkDefault pkgs.rofi;
    enable = true;
    font = "Hack Nerd Font 14";
    plugins = with pkgs; [ rofi-calc rofi-emoji rofi-power-menu ];
  };

  services.blueman-applet.enable = {
    "x86_64-linux" = true;
    "aarch64-linux" = false;
    "aarch64-darwin" = false;
  }."${currentSystem}"; # bluetooth

  services.dunst = { enable = true; };
}


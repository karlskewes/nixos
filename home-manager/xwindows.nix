# X Windows additional configuration dependent on home-manager
{ config, pkgs, ... }:

{
  xdg.configFile."i3/config".text = builtins.readFile ../dotfiles/i3;
  xdg.configFile."discord/settings.json".text = ''
    {
      "BACKGROUND_COLOR": "#202225",
      "SKIP_HOST_UPDATE": true
    }
  '';

  # required for google-chrome
  nixpkgs.config = { allowUnfree = true; };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

    i3lock-fancy
    google-chrome
    libnotify # required by dunst
    pavucontrol
    qalculate-gtk

    # move to programs.rofi.plugins after 21.05
    rofi-calc
    rofi-emoji
    rofi-power-menu
  ];

  programs.i3status.enable = true;

  programs.kitty = {
    enable = true;
    font.name = "Hack Nerd Font";
    settings = { enable_audio_bell = false; };
  };

  programs.rofi = {
    enable = true;
    font = "Hack Nerd Font 14";
    # not in 21.05
    # plugins = with pkgs; [
    #   rofi-calc
    #   rofi-emoji
    #   rofi-power-menu
    # ];
  };

  services.dunst = { enable = true; };

  services.flameshot = { enable = true; };

  services.redshift = {
    enable = true;
    dawnTime = "07:00";
    duskTime = "18:00";
    tray = true;
  };

  services.screen-locker = {
    enable = true;
    inactiveInterval = 10; # minutes
    lockCmd =
      "\${pkgs.i3lock-fancy}/bin/i3lock-fancy & sleep 5 && xset dpms force off";
    # disable xautolock when mouse in bottom right corner
    xautolockExtraOptions = [ "-corners" "000-" ];
  };

  xsession = {
    numlock.enable = true;
    # Make cursor not tiny on HiDPI screens
    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      # size = 64;
    };
  };

}

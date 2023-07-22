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

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })

    firefox
    i3lock-fancy
    google-chrome
    gwenview # image viewer & editor (crop, resize)
    libnotify # required by dunst
    pavucontrol
    qalculate-gtk
    rofi-power-menu # doesn't work as extra package
  ];

  home.pointerCursor = {
    x11.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    # size = 64;
  };

  programs.i3status.enable = true;

  programs.kitty = {
    enable = true;
    font.name = "Hack Nerd Font";
    settings = { enable_audio_bell = false; };
    extraConfig = ''
      map ctrl+shift+enter new_window_with_cwd
    '';
  };

  programs.rofi = {
    enable = true;
    font = "Hack Nerd Font 14";
    plugins = with pkgs; [ rofi-calc rofi-emoji rofi-power-menu ];
  };

  services.dunst = { enable = true; };

  services.flameshot = { enable = true; };

  # services.notify-osd.enable = true;

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
      "${pkgs.i3lock-fancy}/bin/i3lock-fancy & sleep 5 && xset dpms force off";
    # disable xautolock when mouse in bottom right corner
    xautolock.extraOptions = [ "-corners" "000-" ];
  };

  xsession = {
    numlock.enable = true;
    initExtra = ''
      # https://www.reddit.com/r/swaywm/comments/i6qlos/how_do_i_use_an_ime_with_sway/g1lk4xh?utm_source=share&utm_medium=web2x&context=3
      export GLFW_IM_MODULE=ibus
      export INPUT_METHOD=ibus
      export QT_IM_MODULE=ibus
      export GTK_IM_MODULE=ibus
      export XMODIFIERS=@im=ibus
      export XIM_SERVERS=ibus
    '';
  };

}

# X Windows additional configuration dependent on home-manager
{ config, lib, pkgs, ... }: {
  imports = [ ./desktop.nix ];

  xdg.configFile."i3/config".text = builtins.readFile ../../../dotfiles/i3;
  xdg.configFile."i3status/config".text =
    builtins.readFile ../../../dotfiles/i3status_config;

  home.packages = with pkgs; [
    i3lock-fancy
    i3status # programs.i3status.enable = true # does not support custom M1 battery config.

    xclip
  ];

  home.pointerCursor = {
    x11.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    # size = 64;
  };

  programs.bash.shellAliases = {
    # Copy Paste to clipboard.
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
  };

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
      "${pkgs.i3lock-fancy}/bin/i3lock-fancy & sleep 5 && xset dpms force off";
    # disable xautolock when mouse in bottom right corner
    xautolock.extraOptions = [ "-corners" "000-" ];
  };

  xsession = {
    enable = true;
    numlock.enable = true;
    initExtra = ''
      eval "$(/run/wrappers/bin/gnome-keyring-daemon --start --daemonize)"
      export SSH_AUTH_SOCK

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

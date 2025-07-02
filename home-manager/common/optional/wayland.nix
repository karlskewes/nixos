{ lib, pkgs, ... }: {
  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  # TODO: Some of these are shared with i3.
  programs.rofi = {
    # package = lib.mkDefault pkgs.rofi;
    enable = true;
    font = "Hack Nerd Font 14";
    plugins = with pkgs; [ rofi-calc rofi-emoji rofi-power-menu ];
    extraConfig = { modi = "window,run,ssh,drun,emoji,calc"; };
  };

  home.packages = with pkgs; [
    rofi-power-menu # doesn't work as extra package
    wl-clipboard

    ferrishot
    grim
    slurp
    grimblast # screenshot combo grim, slurp, etc
    swappy # screenshot annotation
    satty # screenshot annotation - use with satty --filename X.png --output-filename Y.png
  ];

  home.pointerCursor = {
    gtk.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = lib.mkDefault 64;
  };

  programs.fish.shellAliases = {
    # Copy Paste to clipboard.
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  programs.bash.shellAliases = {
    # Copy Paste to clipboard.
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  programs.rofi = { package = pkgs.rofi-wayland; };
  programs.waybar = { enable = true; };

  services.playerctld.enable = true;
  services.swayosd.enable = true;
  services.wlsunset = {
    enable = true;
    sunrise = "06:00";
    sunset = "19:00";
  };
}

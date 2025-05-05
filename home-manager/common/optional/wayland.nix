{ lib, pkgs, ... }: {
  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  home.packages = with pkgs; [
    wl-clipboard

    grim
    slurp
    grimblast # screenshot combo grim, slurp, etc
    swappy # screenshot annotation
    satty # screenshot annotation
  ];

  home.pointerCursor = {
    gtk.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = lib.mkDefault 64;
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

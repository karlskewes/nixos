{ pkgs, lib, ... }: {
  imports = [ ./desktop.nix ];

  home.sessionVariables = { NIXOS_OZONE_WL = "1"; };

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

  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" "ssh" ];
  };

  xdg.portal.extraPortals =
    [ pkgs.xdg-desktop-portal-cosmic pkgs.xdg-desktop-portal-gtk ];
}

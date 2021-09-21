{ config, pkgs, ... }:

{
  imports = [ ./dev.nix ./xwindows.nix ];

  home.packages = with pkgs; [ discord slack ];

  programs.git = { userEmail = "karl.skewes@gmail.com"; };

  # Make terminal not tiny on HiDPI screens
  xresources.properties = { "Xft.dpi" = "109"; };
}

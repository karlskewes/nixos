{ config, pkgs, ... }:

# laptop not server

{
  imports = [ ./dev.nix ./xwindows.nix ];

  home.packages = with pkgs; [ slack ];

  programs.git = { userEmail = "karl.skewes@gmail.com"; };
}

{ config, pkgs, ... }:

# laptop not server

{
  imports = [
    ./dev.nix
  ];

  programs.git = {
    userEmail = "karl.skewes@gmail.com";
  };
}

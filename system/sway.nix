{ config, pkgs, ... }:

{
  imports = [
    ./wayland.nix
  ];

  # setup windowing environment
  services.xserver = {
    displayManager = {
      # defaultSession = "sway";
    };

  };
}

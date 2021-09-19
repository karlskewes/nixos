# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan / machine config
    ./hardware-configuration-karl-mac-vmware.nix
    ./base.nix
    ./xserver.nix
  ];

  # Define your hostname.
  networking.hostName = "karl-mac-vmware";

  environment.systemPackages = with pkgs;
    [
      # This is needed for the vmware user tools clipboard to work.
      # You can test if you don't need this by deleting this and seeing
      # if the clipboard sill works.
      gtkmm3
    ];

  hardware.video.hidpi.enable = true;

  services.xserver.dpi = 220;

  virtualisation.vmware.guest.enable = true;
}

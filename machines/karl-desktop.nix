# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan / machine config
    ./hardware-configuration-karl-desktop.nix
    ./base.nix
    ./xserver.nix
  ];

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "f299660e";
  # Define your hostname.
  networking.hostName = "karl-desktop";
  networking.nameservers = [ "1.1.1.1" ];

  boot.supportedFilesystems = [ "zfs" ];
  networking.interfaces.enp8s0.useDHCP = true;
}

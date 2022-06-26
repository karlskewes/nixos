{ config, pkgs, lib, currentSystemName, ... }: {
  # NetworkManager seems to require X11?
  # networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  environment.systemPackages = with pkgs; [ libraspberrypi ];
  # https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3
  hardware.enableRedistributableFirmware = true;
  # additional configuration required to enable bluetooth
  # sdImage = {
  #   imageBaseName = "${currentSystemName}-nixos-sd-image";
  #   compressImage = false;
  # };
}

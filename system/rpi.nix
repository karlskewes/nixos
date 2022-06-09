{ config, pkgs, ... }: {
  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "c3f22703";
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [ libraspberrypi ];
  # https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3
  hardware.enableRedistributableFirmware = true;
  # additional configuration required to enable bluetooth
}

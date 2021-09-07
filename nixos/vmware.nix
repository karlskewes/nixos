{ config, pkgs, ... }:

{
  imports = [ ./configuration.nix ];

  environment.systemPackages = with pkgs;
    [
      # This is needed for the vmware user tools clipboard to work.
      # You can test if you don't need this by deleting this and seeing
      # if the clipboard sill works.
      gtkmm3
    ];

  hardware.video.hidpi.enable = true;

  # Disable the firewall since we're in a VM and we want to make it
  # easy to visit stuff in here. We only use NAT networking anyways.
  networking.firewall.enable = false;

  virtualisation.vmware.guest.enable = true;
}

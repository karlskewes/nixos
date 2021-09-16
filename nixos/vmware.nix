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

  virtualisation.vmware.guest.enable = true;
}

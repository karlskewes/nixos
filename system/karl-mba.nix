{ config, pkgs, ... }: {

  imports = [
    ./base.nix
    ./xserver.nix
  ];

  powerManagement.enable = true;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "b4db4b8f";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  networking.wireless.enable = false;
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  # Specify path to peripheral firmware files copied during initial
  # installation.
  hardware.asahi.peripheralFirmwareDirectory = /etc/nixos/firmware;
  # Or disable extraction and management of them completely (no wifi though).
  # hardware.asahi.extractPeripheralFirmware = false;

  # Build the Asahi Linux kernel with additional experimental "edge" configuration options.
  # https://github.com/tpwrules/nixos-apple-silicon/blob/main/apple-silicon-support/modules/kernel/edge.nix
  options.hardware.asahi.addEdgeKernelConfig = true;

  # TODO: Graphics, if anything?
  # nixpkgs.config.packageOverrides = pkgs: {
  #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  # };
  # hardware.opengl.extraPackages = with pkgs; [
  #   intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #   vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #   vaapiVdpau
  #   libvdpau-va-gl
  # ];

  # TODO: check now that pipewire enabled
  # Need full for bluetooth support
  # hardware.bluetooth.enable = true;
  # hardware.pulseaudio.package = pkgs.pulseaudioFull;
}

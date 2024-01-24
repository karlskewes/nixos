{ config, pkgs, ... }: {

  imports = [ ./base.nix ./i3.nix ];

  powerManagement.enable = true;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "b4db4b8f";

  # Specify path to peripheral firmware files copied during initial
  # installation.
  sound.enable = true;
  hardware.asahi = {
    peripheralFirmwareDirectory = /etc/nixos/firmware;
    withRust = true;
    addEdgeKernelConfig = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
  };
  # Or disable extraction and management of them completely (no wifi though).
  # hardware.asahi.extractPeripheralFirmware = false;

  services.logind.lidSwitch = "suspend";
}

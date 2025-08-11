{ lib, ... }: {

  imports = [
    ./hardware-configuration.nix

    ../common/global

    ../common/optional/cosmic.nix
    # ../common/optional/hyprland.nix
    # ../common/optional/zfs.nix
  ];

  # zfsBootUnlock = {
  #   enable = false;
  #   authorizedKeys = [
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew hello@karlskewes.com"
  #   ];
  #   interfaces = [ "cdc-ncm" ];
  # };

  boot.kernelParams = [
    "psmouse.synaptics_intertouch=0"
  ]; # Enables libinput settings to take effect.
  boot.zfs.removeLinuxDRM = true;
  virtualisation.docker = {
    storageDriver = lib.mkForce "overlay2";
  }; # TODO, change after migrate to ZFS

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "b4db4b8f";

  hardware.asahi = {
    enable = true;
    # Specify path to peripheral firmware files copied during initial installation.
    peripheralFirmwareDirectory = /etc/nixos/firmware;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
  };
  # Or disable extraction and management of them completely (no wifi though).
  # hardware.asahi.extractPeripheralFirmware = false;

  powerManagement.enable = true;

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  services.logind.lidSwitch = "suspend";

  # dock "displaylink" driver must be manually installed, see run.sh
  # TODO: convert to nix
  # modesetting required I think for actual display output to dock
  # TODO: disable for hyprland
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
}

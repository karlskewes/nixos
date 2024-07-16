{ config, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix

    ../common/global

    ../common/optional/i3.nix
    ../common/optional/zfs.nix
  ];

  powerManagement.enable = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "624e2a63";
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    vaapiVdpau
    libvdpau-va-gl
  ];
}

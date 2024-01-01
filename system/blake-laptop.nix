{ config, pkgs, ... }: {

  imports = [ ./base.nix ./i3.nix ./zfs.nix ];

  powerManagement.enable = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "624e2a63";
  networking.networkmanager.enable = true;
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    vaapiVdpau
    libvdpau-va-gl
  ];

  # TODO: check now that pipewire enabled
  # Need full for bluetooth support
  # hardware.bluetooth.enable = true;
  # hardware.pulseaudio.package = pkgs.pulseaudioFull;
}

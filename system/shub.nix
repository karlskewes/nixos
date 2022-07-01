{ config, pkgs, ... }: {
  # Define hostId for zfs pool machine 'binding'
  # :read !echo <hostname> | md5sum | cut -c1-8
  networking.hostId = "b38b36dc";
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
  # Need full for bluetooth support
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
}

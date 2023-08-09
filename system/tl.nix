{ config, pkgs, ... }: {
  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "1014a839";
  networking.interfaces.enp1s0f0.useDHCP = true; # onboard
  networking.interfaces.enp5s0f4u1u3c2.useDHCP = true; # dock
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.upscaleDefaultCursor = true;
  services.xserver.dpi = 180;

  services = {
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
  };

  # Need full for bluetooth support
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # required to use dvd/cdrom in some applications
  programs.dconf.enable = true;
}

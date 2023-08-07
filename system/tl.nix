{ config, pkgs, ... }: {
  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4

  networking.hostId = "1014a839";
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];

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

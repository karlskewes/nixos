{ config, pkgs, ... }: {
  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "f299660e";
  networking.interfaces.enp9s0.useDHCP = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # required to use dvd/cdrom in some applications
  programs.dconf.enable = true;
}

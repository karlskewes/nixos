{ ... }: {
  imports = [
    ./hardware-configuration.nix

    ../common/global

    ../common/optional/hyprland.nix
    # ../common/optional/i3.nix
    ../common/optional/zfs.nix
  ];

  zfsBootUnlock = {
    enable = false;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew hello@karlskewes.com"
    ];
    interfaces = [
      # whatever devices declared here must have a network connection otherwise boot hangs before
      # `starting device mapper and LVM...`.
      # "r8169" # onboard
      # "cdc_ether" # displaylink # might not be supported at boot.
    ];
  };

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "1014a839";
  networking.interfaces.enp1s0f0.useDHCP = true; # onboard
  # networking.interfaces.enp5s0f4u1u3c2.useDHCP = true; # dock # unused currently
  # hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr ]; # broken

  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  powerManagement.enable = true;

  # required to use dvd/cdrom in some applications
  programs.dconf.enable = true;

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  services.logind.lidSwitch = "suspend";

  # dock "displaylink" driver must be manually installed, see run.sh
  # TODO: convert to nix
  # modesetting required I think for actual display output to dock
  services.xserver.videoDrivers = [ "displaylink" "modesetting" "amdgpu" ];
  services.xserver.upscaleDefaultCursor = true; # hidpi
  services.xserver.dpi = 109;
}

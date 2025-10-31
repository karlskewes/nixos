{ pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix

    ../common/global

    ../common/optional/i3.nix
    ../common/optional/zfs.nix
  ];

  powerManagement.enable = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;

  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

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

  services.clamav = {
    daemon.enable = true;
    daemon.settings = {
      # exclude various package caches.
      "ExcludePath" =
        [ "/node_modules/" "/go/" "/\\.rustup/" "/\\.yarn/" "/yarn/berry/" ];

      # $ journalctl -u clamdscan.service
      # `clamdscan[22040]: LibClamAV Warning: cli_realpath: Invalid arguments.`
      # $ cd DIRECTORY_TO_SCAN # cd /var/lib
      # $ find . | awk 'FS="/" {print(NF)}' | sort --general-numeric-sort | tail --lines 1
      # 26
      MaxDirectoryRecursion = 30;
    };
    scanner.enable = true;
    updater.enable = true;
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend";
}

{ config, lib, pkgs, currentSystem, ... }:

{
  environment.systemPackages = with pkgs; [ simple-scan ];

  # i18n  {
  #   inputMethod = {
  #     enabled = "ibus";
  #     ibus.engines = with pkgs.ibus-engines; [ mozc ];
  #   };
  # };

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez5-experimental;
    # [NEW] Device 94:DB:56:E0:AE:54 WH-1000XM4
  };
  services.blueman.enable = true; # bluetooth

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  hardware.printers.ensureDefaultPrinter = "Brother";
  hardware.printers.ensurePrinters = [{
    name = "Brother";
    deviceUri = "ipp://BRW1CBFC0F36D0B/ipp";
    model = "everywhere";
  }];

  hardware.sane = {
    enable = {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";

    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "MFC-L2713DW";
          ip = "192.168.1.104";
          # nodename = "BRW1CBFC0F36D0B";
        };
      };
    };
    # brscan5 = { enable = true; };
  };

  # scanning
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = false; # using pipewire
  sound.enable = lib.mkDefault false; # Using pipewire below
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}

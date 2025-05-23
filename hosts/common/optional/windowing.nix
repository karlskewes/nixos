{ config, lib, pkgs, currentSystem, ... }:

{
  # https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
  environment.pathsToLink =
    [ "/share/xdg-desktop-portal" "/share/applications" ];
  environment.systemPackages = with pkgs; [ libinput simple-scan ];

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

  hardware.graphics.enable = true;

  # hardware.printers.ensureDefaultPrinter = "Brother";
  # hardware.printers.ensurePrinters = [{
  #   name = "Brother";
  #   deviceUri = "ipp://BRW1CBFC0F36D0B/ipp";
  #   model = "everywhere";
  # }];

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

  # required to use dvd/cdrom in some applications
  programs.dconf.enable = true;

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

  services.libinput.enable = true;
  # Confirm below with `xinput list-props <id>`
  services.libinput.touchpad.disableWhileTyping = true; # ineffective.
  services.libinput.touchpad.tapping =
    false; # disabling due to undesired focus changes. Right click = Shift+F10(+fn)

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false; # using pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}

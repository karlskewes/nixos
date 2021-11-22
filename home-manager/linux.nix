{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "karl";
  home.homeDirectory = "/home/karl";

  home.packages = with pkgs; [
    pciutils
    psmisc
    usbutils
  ];

  programs.gpg = {
    enable = true;
    settings = { pinentry-mode = "loopback"; };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "tty";

    # cache the keys forever, rotate as require
    maxCacheTtl = 31536000;
    maxCacheTtlSsh = 31536000;
    # cache passwords for 12 hours
    defaultCacheTtl = 43200;
    defaultCacheTtlSsh = 43200;

    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}

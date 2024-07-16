{ config, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

in {
  programs.gpg = {
    enable = true;
    settings = { pinentry-mode = "loopback"; };
  };

  services.gpg-agent = {
    enable = isLinux;
    enableSshSupport = true;
    pinentryPackage =
      if isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;

    # cache the keys forever, rotate as require
    maxCacheTtl = 31536000;
    maxCacheTtlSsh = 31536000;
    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    defaultCacheTtlSsh = 31536000;

    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}

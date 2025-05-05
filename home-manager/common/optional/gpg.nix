{ config, pkgs, isDarwin, isLinux, ... }:

{
  home.packages = with pkgs;
    [ ] ++ (lib.optionals isLinux [
      seahorse
      pinentry # gpg add ssh key
      # export GPG_TTY=$(tty)
      # export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      # gpg ssh-add -c -t 31536000 path/to/id_rsa
    ]);

  programs.gpg = {
    enable = true;
    settings = { pinentry-mode = "loopback"; };
  };

  services.gpg-agent = {
    enable = isLinux;
    enableSshSupport = true;
    pinentry.package =
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

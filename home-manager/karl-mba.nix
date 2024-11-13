({ config, lib, pkgs, isDarwin, isLinux, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/dev.nix
    ./common/optional/gpg.nix
  ] ++ (lib.optionals isDarwin [ ])
    ++ (lib.optionals isLinux [ ./common/optional/xwindows.nix ]);

  home.packages = with pkgs;
    [ ] ++ (lib.optionals isLinux [
      asahi-bless
      asahi-btsync
      asahi-nvram
      asahi-wifisync

      calibre
    ]);

  home.pointerCursor.size = lib.mkIf isLinux 128; # 180; # 4k
  xresources.properties = lib.mkIf isLinux { "Xft.dpi" = "122"; };
})


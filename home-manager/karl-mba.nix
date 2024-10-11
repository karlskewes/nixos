({ config, lib, pkgs, ... }:
  let
    isDarwin = pkgs.stdenv.isDarwin;
    isLinux = pkgs.stdenv.isLinux;

  in {
    imports = [
        ./user-karl.nix

        ./common/global

        ./common/optional/dev.nix
        ./common/optional/gpg.nix
      ];
    # ++ (lib.optionals isDarwin [ ])
    # ++ (lib.optionals isLinux [ ./common/optional/xwindows.nix ]);

    home.packages = with pkgs;
      [ ] ++ (lib.optionals isLinux [
        asahi-bless
        asahi-btsync
        asahi-nvram
        asahi-wifisync

        calibre
      ]);

    home.pointerCursor = lib.mkIf isLinux {
      sor.size = 180; # 4k
      size = 128;
      name = "Vanilla-DMZ";
    };
    xresources.properties = lib.mkIf isLinux { "Xft.dpi" = "122"; };
  })


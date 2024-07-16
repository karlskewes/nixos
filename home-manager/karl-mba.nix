({ config, lib, pkgs, ... }:
  let
    isDarwin = pkgs.stdenv.isDarwin;
    isLinux = pkgs.stdenv.isLinux;

  in {
    # imports = [ ./user-karl.nix ] ++
    # (lib.optionals isLinux [ ./xwindows.nix ]);
    imports = [ ./user-karl.nix ./dev.nix ./gpg.nix ./xwindows.nix ];

    home.packages = with pkgs;
      [ ] ++ (lib.optionals isLinux [
        asahi-bless
        asahi-btsync
        asahi-nvram
        asahi-wifisync
      ]);

    # home.pointerCursor.size = 180; # 4k
    home.pointerCursor.size = 128;
    home.pointerCursor.name = "Vanilla-DMZ";
    xresources.properties = { "Xft.dpi" = "122"; };
  })


({ config, lib, pkgs, isDarwin, isLinux, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/dev.nix
    ./common/optional/gpg.nix
    ./common/optional/hyprland.nix
    # ./common/optional/i3.nix
    # ./common/optional/sway.nix
  ] ++ (lib.optionals isDarwin [ ])
    ++ (lib.optionals isLinux [ ./common/optional/desktop.nix ]);

  home.packages = with pkgs;
    [ ] ++ (lib.optionals isLinux [
      asahi-bless
      asahi-btsync
      asahi-nvram
      asahi-wifisync

      calibre
    ]);

  # TODO: only if i3
  # home.pointerCursor = lib.mkIf isLinux { size = 128; }; # 180; # 4k
  # xresources.properties = lib.mkIf isLinux { "Xft.dpi" = "122"; };
})


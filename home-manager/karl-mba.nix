({ lib, pkgs, isDarwin, isLinux, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/dev.nix
    ./common/optional/gpg.nix
  ] # #
    ++ (lib.optionals isDarwin [ ])
    # #
    ++ (lib.optionals isLinux [
      ./common/optional/cosmic.nix
      # ./common/optional/i3.nix
      # ./common/optional/sway.nix
      # ./common/optional/hyprland.nix
    ]);

  common.git.signing = { enable = true; };

  desktop.firefox = {
    enable = true;
    users = [ "karl" ];
  };

  home.packages = with pkgs;
    [ ] ++ (lib.optionals isLinux [
      asahi-bless
      asahi-btsync
      asahi-nvram
      asahi-wifisync

      # calibre # 7.26.0 broken errors during test_piper, re-add when fixed.
    ]);
})


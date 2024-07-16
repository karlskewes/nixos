({ config, pkgs, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/dev.nix
    ./common/optional/gpg.nix
    ./common/optional/xwindows.nix
  ];

  xresources.properties = { "Xft.dpi" = pkgs.lib.mkDefault "109"; }; # 180 on 4k
})

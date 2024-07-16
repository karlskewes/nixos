({ config, pkgs, ... }: {
  imports = [ ./user-karl.nix ./dev.nix ./gpg.nix ./xwindows.nix ];
  xresources.properties = { "Xft.dpi" = pkgs.lib.mkDefault "109"; }; # 180 on 4k
})

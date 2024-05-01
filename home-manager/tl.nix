({ config, pkgs, ... }: {
  imports = [ ./user-karl.nix ./xwindows.nix ];
  xresources.properties = { "Xft.dpi" = pkgs.lib.mkDefault "109"; }; # 180 on 4k
})

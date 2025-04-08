({ config, pkgs, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/dev.nix
    ./common/optional/gpg.nix
    ./common/optional/hyprland.nix
    # ./common/optional/i3.nix
  ];

  desktop.firefox = {
    enable = true;
    users = [ "karl" ];
  };

  # TODO: only if i3
  # xresources.properties = { "Xft.dpi" = pkgs.lib.mkDefault "109"; }; # 180 on 4k
})

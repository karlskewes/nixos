({ config, pkgs, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/dev.nix
  ];

  home.packages = with pkgs; [ tmux ];
})

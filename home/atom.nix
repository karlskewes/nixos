({ config, pkgs, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global
  ];

  home.packages = with pkgs; [ tmux ];
})

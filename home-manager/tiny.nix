({ config, pkgs, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/dev.nix
    ./common/optional/gpg.nix
  ];

  home.packages = with pkgs; [ tmux ];
})

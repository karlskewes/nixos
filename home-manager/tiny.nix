({ config, pkgs, ... }: {
  imports = [ ./user-karl.nix ];
  home.packages = with pkgs; [ tmux ];
})

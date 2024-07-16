({ config, pkgs, ... }: {
  imports = [ ./user-karl.nix ./dev.nix ./gpg.nix ];
  home.packages = with pkgs; [ tmux ];
})

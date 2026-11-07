(
  { pkgs, ... }:
  {
    imports = [
      ./user-karl.nix

      ./modules
    ];

    # Fix terminal for SSH with colour.
    # WARNING: terminal is not fully functional
    programs.bash.initExtra = ''
      TERM=xterm-256color
    '';
    home.packages = with pkgs; [ tmux ];
  }
)

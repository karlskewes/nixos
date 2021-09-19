# X Windows additional configuration dependent on home-manager
{ config, pkgs, ... }:

{
  xdg.configFile."i3/config".text = builtins.readFile ../dotfiles/i3;

  # required for google-chrome
  nixpkgs.config = { allowUnfree = true; };

  home.packages = with pkgs; [
    google-chrome
    libnotify # required by dunst
    pavucontrol
    qalculate-gtk

    # move to programs.rofi.plugins after 21.05
    rofi-calc
    rofi-emoji
    rofi-power-menu
  ];

  programs.i3status = {
    enable = true;

    modules = {
      # VM so these aren't available
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  programs.kitty = {
    enable = true;
    settings = { enable_audio_bell = false; };
  };

  programs.rofi = {
    enable = true;
    font = "Monospace 14";
    # not in 21.05
    # plugins = with pkgs; [
    #   rofi-calc
    #   rofi-emoji
    #   rofi-power-menu
    # ];
  };

  services.dunst = { enable = true; };

  services.flameshot = { enable = true; };
}

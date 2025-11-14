{ pkgs, ... }:

{
  imports = [ ./wayland.nix ];

  programs.sway = {
    enable = true;
    xwayland.enable = true;
  };

  services.upower.enable = true;

  services.greetd.settings.default_session = {
    command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
  };
}

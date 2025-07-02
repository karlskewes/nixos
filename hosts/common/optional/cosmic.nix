{ ... }:

{
  imports = [ ./windowing.nix ];

  # xdg defaults not working.
  # https://github.com/lilyinstarlight/nixos-cosmic/issues/273
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
  '';

  # enable clipboard management: zwlr_data_control_manager_v1
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

  # enable Observability
  # systemd.packages = [ pkgs.observatory ]; # not available
  # systemd.services.monitord.wantedBy = [ "multi-user.target" ];

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  security.pam.services.cosmic.enableGnomeKeyring = true;

  services.dbus.enable = true;
}

{ ... }:

{
  imports = [ ./windowing.nix ];

  # xdg defaults not working.
  # https://github.com/lilyinstarlight/nixos-cosmic/issues/273
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
  '';
  #
  # https://support.system76.com/articles/audio/#audio-crackling-or-hardware-clicking
  # services.pipewire.extraConfig.pipewire."91-audio-stutter" = {
  #   "session.suspend-timeout-seconds" = 0;
  # };
  # services.pipewire.extraConfig.pipewire-pulse."91-audio-stutter" = {
  #   "session.suspend-timeout-seconds" = 0;
  # };

  # journalctl -u bluetooth
  # May 17 18:35:39 karl-mba bluetoothd[927]: src/profile.c:record_cb() Unable to get Hands-Free Voice gateway SDP record: Host is down
  # hardware.bluetooth.settings.General.ControllerMode = "bredr";

  # services.power-profiles-daemon.enable = false;

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

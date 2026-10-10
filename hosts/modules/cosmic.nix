{ config, lib, ... }:

{
  imports = [ ./windowing.nix ];

  config = lib.mkMerge [
    {
      # xdg defaults not working.
      # https://github.com/lilyinstarlight/nixos-cosmic/issues/273
      systemd.user.settings.Manager.DefaultEnvironment =
        "PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";

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

    # avoid WIFI crash due to System76 power-daemon enabled by CosmicDE.
    (lib.mkIf (config.hardware.asahi.enable or false) {
      services.power-profiles-daemon.enable = true; # prevents system76 ones from being enabled.

      # reproduce WIFI crash due to System76 power daemon enabled by CosmicDE.
      # services.power-profiles-daemon.enable = lib.mkForce false;
      # hardware.system76.power-daemon.enable = lib.mkForce true;
      # services.system76-scheduler.enable = lib.mkForce false;
    })
  ];
}

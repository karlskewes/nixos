{ ... }:

{
  imports = [ ./windowing.nix ];

  # https://support.system76.com/articles/audio/#audio-crackling-or-hardware-clicking
  services.pipewire.extraConfig.pipewire."91-audio-stutter" = {
    "session.suspend-timeout-seconds" = 0;
  };
  services.pipewire.extraConfig.pipewire-pulse."91-audio-stutter" = {
    "session.suspend-timeout-seconds" = 0;
  };

  hardware.bluetooth.settings.General.ControllerMode = "bredr";

  services.power-profiles-daemon.enable = false;

  nix.settings = {
    substituters = [ "https://cosmic.cachix.org/" ];
    trusted-public-keys =
      [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };

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

{ pkgs, ... }:

{
  imports = [ ./windowing.nix ];

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
  services.displayManager.environment = { XCURSOR_SIZE = 16; };

  security.pam.services.cosmic.enableGnomeKeyring = true;

  services.dbus.enable = true;
}

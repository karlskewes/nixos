# based on: https://github.com/mitchellh/nixos-config/blob/main/lib/mkvm.nix
# This function creates a standalone Home Manager configuration.
name:
{ nixpkgs, home-manager, system, user, emailAddress, overlays, homeDirectory
, stateVersion, homeConfig ? { }, hmExtraModules ? [ ] }:

home-manager.lib.homeManagerConfiguration rec {
  inherit system homeDirectory stateVersion;
  username = user;
  configuration = { config, pkgs, username, ... }:
    {
      nixpkgs.overlays = overlays;

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [ "google-chrome" "slack" ];

    } + homeConfig;

  extraModules = hmExtraModules;
  extraSpecialArgs = {
    currentUser = user;
    currentEmailAddress = emailAddress;
  };

}

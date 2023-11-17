# based on: https://github.com/mitchellh/nixos-config/blob/main/lib/mkvm.nix
# This function creates a standalone Home Manager configuration.
name:
{ nixpkgs, home-manager, system, user, emailAddress, overlays, stateVersion
, hmExtraModules ? [ ] }:

home-manager.lib.homeManagerConfiguration rec {
  pkgs = nixpkgs.legacyPackages.${system};
  modules = hmExtraModules ++ [{
    nixpkgs.overlays = overlays;
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (nixpkgs.lib.getName pkg) [ "slack" ];
  }];

  extraSpecialArgs = {
    currentUser = user;
    currentEmailAddress = emailAddress;
    currentStateVersion = stateVersion;
  };
}

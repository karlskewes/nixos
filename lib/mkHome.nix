# based on: https://github.com/mitchellh/nixos-config/blob/main/lib/mkvm.nix
# This function creates a standalone Home Manager configuration.
name:
{ nixpkgs
, home-manager
, system
, user
, overlays
, stateVersion
, hmExtraModules ? [ ]
, hmSharedModules ? [ ]
}:

home-manager.lib.homeManagerConfiguration rec {
  pkgs = nixpkgs.legacyPackages.${system};
  modules = hmExtraModules ++ [{
    nixpkgs.overlays = overlays;
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (nixpkgs.lib.getName pkg) nixpkgs.lib.mkDefault [ "slack" ];
  }];
  sharedModules = hmSharedModules;

  extraSpecialArgs = {
    currentUser = user;
    currentStateVersion = stateVersion;
  };
}

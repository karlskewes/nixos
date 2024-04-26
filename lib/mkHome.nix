# based on: https://github.com/mitchellh/nixos-config/blob/main/lib/mkvm.nix
# This function creates a standalone Home Manager configuration.
name:
{ nixpkgs, home-manager, overlays, system, user, stateVersion
, extraModules ? [ ] }:

# TODO: consider nix-darwin support:
# https://nix-community.github.io/home-manager/index.xhtml#sec-install-nix-darwin-module
# https://github.com/mitchellh/nixos-config/blob/75fe7a47f88fff0c01891d90c2153e8a14935a3e/lib/mksystem.nix#L24

let

  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  hm =
    if isDarwin then home-manager.darwinModules else home-manager.nixosModules;

in hm.lib.homeManagerConfiguration rec {
  pkgs = nixpkgs.legacyPackages.${system};
  modules = extraModules ++ [{
    nixpkgs.overlays = overlays;
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (nixpkgs.lib.getName pkg) nixpkgs.lib.mkDefault [ "slack" ];
  }];
  sharedModules = [ ../home-manager/shared.nix ];

  extraSpecialArgs = {
    currentUser = user;
    currentStateVersion = stateVersion;
  };
}

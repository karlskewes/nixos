# Based on: https://github.com/mitchellh/nixos-config/blob/74ede9378860d4807780eac80c5d685e334d59e9/lib/mksystem.nix
name:
{ nixpkgs
, nix-darwin ? { }
, home-manager
, overlays
, configRev
, system
, isDarwin ? false
, user
, stateVersion
, extraModules ? [ ]
}:

let
  isLinux = !isDarwin;
  hm =
    if isDarwin then home-manager.darwinModules else home-manager.nixosModules;

  homeModule = ../home-manager/${name}.nix;

  systemFunc =
    if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;

  hostConfig =
    if isDarwin then ../hosts/common/optional/darwin.nix else ../hosts/${name};

in
systemFunc rec {
  inherit system;

  modules = extraModules ++ [
    # expose arguments for modules to use as parameters
    {
      config._module.args = {
        currentRevision = configRev;
        currentStateVersion = stateVersion;
        currentSystem = system;
        currentSystemName = name;
        currentUsers = [ user ];
      };
    }

    { nixpkgs.overlays = overlays; }

    ({ config, lib, ... }: { nixpkgs.config.allowUnfree = lib.mkDefault true; })

    hostConfig

    hm.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users = { ${user} = homeModule; };

      # expose arguments for imports to use as parameters
      home-manager.extraSpecialArgs = {
        currentStateVersion = stateVersion;
        currentSystem = system;
      };
      home-manager.sharedModules = [ ];
    }
  ];
}

# based on: https://github.com/mitchellh/nixos-config/blob/main/lib/mkvm.nix
# This function creates a NixOS system based for a particular architecture.
name:
{ nixpkgs
, home-manager
, nix-extra
, overlays
, configRev
, system
, user
, stateVersion
, extraModules ? [ ]
, homeConfig ? { }
, homeShared ? [ ]
}:

nixpkgs.lib.nixosSystem rec {
  inherit system;

  modules = extraModules ++ [
    # expose arguments for modules to use as parameters
    {
      config._module.args = {
        currentUser = user;
        currentSystem = system;
        currentSystemName = name;
        currentRevision = configRev;
      };
    }

    { nixpkgs.overlays = overlays; }

    ({ config, lib, ... }: { nixpkgs.config.allowUnfree = lib.mkDefault true; })

    ../hardware/${name}.nix
    ../system/${name}.nix

    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = homeConfig;
      # expose arguments for imports to use as parameters
      home-manager.extraSpecialArgs = {
        currentStateVersion = stateVersion;
      };
      home-manager.sharedModules = homeShared;
    }
  ];
}

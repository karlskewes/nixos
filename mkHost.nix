# based on: https://github.com/mitchellh/nixos-config/blob/main/lib/mkvm.nix
# This function creates a NixOS system based for a particular architecture.
name:
{ nixpkgs, home-manager, system, user, emailAddress, overlays, nix-extra
, machineConfig ? { }, homeConfig ? { } }:

nixpkgs.lib.nixosSystem rec {
  inherit system;

  modules = [
    { nixpkgs.overlays = overlays; }
    ({ config, ... }: {
      # TODO: restrict this list?
      nixpkgs.config = { allowUnfree = true; };
    })
    machineConfig

    "${nix-extra.outPath}/nixos.nix"
    ./machines/${name}.nix
    ./machines/base.nix
    ./machines/xserver.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = homeConfig;
      # We expose some extra arguments so that our imports can parameterize
      # better based on these values.
      home-manager.extraSpecialArgs = {
        currentUser = user;
        currentEmailAddress = emailAddress;
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentUser = user;
        currentSystem = system;
        currentSystemName = name;
      };
    }
  ];
}

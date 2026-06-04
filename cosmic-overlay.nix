(
  final: prev:
  let
    mkCosmicOverride =
      {
        repo,
        rev,
        srcHash,
        depsHash,
        version,
      }:
      let
        src = prev.fetchFromGitHub {
          owner = "karlskewes";
          inherit repo rev;
          hash = srcHash;
        };
      in
      prev.${repo}.overrideAttrs (_: {
        inherit src version;
        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = depsHash;
        };
      });
  in
  {
    # Adding or updating a package:
    #   1. Set rev to the new commit SHA and version to a descriptive string.
    #   2. Set srcHash = prev.lib.fakeHash
    #      Run: nix build '.#nixosConfigurations.karl-mba.pkgs.<name>' --no-link 2>&1 | grep "got:"
    #      Update srcHash with the printed value.
    #   3. Set depsHash = prev.lib.fakeHash
    #      Run the same nix build command again.
    #      Update depsHash with the printed value.
    #   4. Run: ./run.sh build
    #
    # Note: override cargoHash via overrideAttrs does NOT work — lib.extendMkDerivation
    # runs extendDrvArgs before overrideAttrs fires so cargoHash never reaches the
    # cargoDeps computation. Override cargoDeps (the fetchCargoVendor FOD) directly.
    #
    # Note: [patch] sections in Cargo.toml are NOT processed by fetchCargoVendor
    # (it reads only Cargo.lock). Cross-repo git deps must be direct references
    # with a pinned rev in Cargo.toml so they appear in Cargo.lock.
    cosmic-comp = mkCosmicOverride {
      repo = "cosmic-comp";
      rev = "ffcec1787342b645859fc99706eb0a7084dd68b9"; # workspace-pinning
      srcHash = "sha256-/t7YmkAnld8uDKp0z0MKaW6I0YxGI6x5gD81cGrUI30=";
      depsHash = "sha256-USJp2Ux7yVkAFCzsiuYqHF0dKTIuot4Ftohj2b5xc9c=";
      version = "workspace-pinning";
    };
    cosmic-settings-daemon = mkCosmicOverride {
      repo = "cosmic-settings-daemon";
      rev = "bf74a86d301881ec7d57678c417a3bea495b7b60"; # workspace-pinning
      srcHash = "sha256-1EpSi4GgNlRvxc2+B8R8XKIbu1gsxVpszoaqzE9itWw=";
      depsHash = "sha256-pvoCqFvMVqNTfdU5WidGijfFNsC9i2XNuNV33F8aKZw=";
      version = "workspace-pinning";
    };
    # shutdown bug
    # xdg-desktop-portal-cosmic = mkCosmicOverride {
    #   repo = "xdg-desktop-portal-cosmic";
    #   rev = "2f1e41ab44df3eeb5832e24262c70fd4c2643009"; # wayland-dispatch-err
    #   srcHash = "sha256-3ttN558z9J2XY5OMAt4SieXDkNw1DZLolJBe5HxYw2Q=";
    #   depsHash = "sha256-/7jxEktXW1+4nFK7ZFUO3oJhmLNuKMwErnqwgjBQiao=";
    #   version = "wayland-dispatch-err";
    # };
  }
)

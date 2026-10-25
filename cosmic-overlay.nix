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
        doCheck = false; # Skip upstream unit tests which does 3 extra fat LTO compiles, swapping.
        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = depsHash;
        };
      });
  in
  {
    # Adding or updating a package:
    #   1. Set rev to the new commit SHA and version to a descriptive string.
    #   2. Set srcHash = "" to force new fetch.
    #      Run: nix build '.#nixosConfigurations.karl-mba.pkgs.<name>' --no-link 2>&1 | grep "got:"
    #      Update srcHash with the printed value.
    #   3. Set depsHash = "" to force new fetch.
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
    # cosmic-comp = mkCosmicOverride {
    #   repo = "cosmic-comp";
    #   rev = "ffcec1787342b645859fc99706eb0a7084dd68b9"; # workspace-pinning
    #   srcHash = "sha256-/t7YmkAnld8uDKp0z0MKaW6I0YxGI6x5gD81cGrUI30=";
    #   depsHash = "sha256-USJp2Ux7yVkAFCzsiuYqHF0dKTIuot4Ftohj2b5xc9c=";
    #   version = "workspace-pinning";
    # };
    cosmic-comp =
      (mkCosmicOverride {
        repo = "cosmic-comp";
        rev = "9909535000e95887cb2d9f5428dc9a7f71c49412"; # nix-flake-workspace-pinning
        srcHash = "sha256-1HprevRVGbVcdh+GJxinJYXrcShs7g5VCoiGCNzWcZk=";
        depsHash = "sha256-xTKboIX/PICoog8xmX7234SduNsO4Vn3m+bwrOymT9w=";
        version = "1.11.0-nix-flake-workspace-pinning";
      }).overrideAttrs
        (old: {
          env = old.env // {
            # Cargo.toml sets lto = "fat". Fat linking uses >16GB memory and takes ~14m vs 3m.
            CARGO_PROFILE_RELEASE_LTO = "thin";
          };
        });
    cosmic-settings-daemon =
      (mkCosmicOverride {
        repo = "cosmic-settings-daemon";
        rev = "af933080654333e60e35426215c42de2b4145530"; # workspace-pinning
        srcHash = "sha256-vwjgZ4RZT0hn9UZHvXxdf9o8JlX5PR7jzdGshBIMqj4=";
        depsHash = "sha256-19GGcZmxq/Yp0A6wnR6Y4zKwZ9EiQBj1i5+D9lDAFz8=";
        version = "1.11.0-workspace-pinning";
      }).overrideAttrs
        # required until pull updated nixpkgs with extra config.
        (
          old: {
            buildInputs = old.buildInputs ++ [
              prev.pipewire
            ];
            nativeBuildInputs = old.nativeBuildInputs ++ [
              prev.pkg-config
              prev.rustPlatform.bindgenHook
            ];
          }
        );
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

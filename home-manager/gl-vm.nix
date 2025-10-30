({ lib, pkgs, isDarwin, isLinux, ... }:
  let
    gdk = pkgs.google-cloud-sdk.withExtraComponents
      (with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]);

  in {
    imports = [
      ./user-karl.nix

      ./common/global

      ./common/optional/dev.nix
    ] # #
      ++ (lib.optionals isDarwin [
        ./common/optional/desktop.nix
        # #
      ])
      # #
      ++ (lib.optionals isLinux [
        ./common/optional/cosmic.nix
        # #
      ]);

    common.git.signing = { enable = true; };

    desktop.firefox = { enable = true; };

    home.packages = with pkgs;
      [
        awscli2
        gdk
        azure-cli

        docker-buildx
        kind
        kubernetes-helm

        gh
        pre-commit
        jsonnet-bundler
        yq
      ] ++ (lib.optionals isDarwin [
        google-chrome # chromium variants not supported on darwin
        slack # not supported on aarch64-linux
      ]) ++ (lib.optionals isLinux [
        chromium
        # #
      ]);
  })

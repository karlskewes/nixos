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
      [ ] ++ (lib.optionals isDarwin [
        google-chrome # chromium variants not supported on darwin
        slack

        awscli2
        gdk
        azure-cli

        docker-buildx
        podman # docker replacement
        podman-compose
        kind
        kubernetes-helm

        gh
        pre-commit
        jsonnet-bundler
        tanka
        yq
      ]) ++ (lib.optionals isLinux [
        asahi-bless
        asahi-btsync
        asahi-nvram
        asahi-wifisync
      ]);
  })

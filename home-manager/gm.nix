(
  {
    lib,
    pkgs,
    isDarwin,
    isLinux,
    ...
  }:
  let
    az = pkgs.azure-cli.withExtensions [ pkgs.azure-cli-extensions.account ];
    gdk = pkgs.google-cloud-sdk.withExtraComponents (
      with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
    );

  in
  {
    imports = [
      ./user-karl.nix

      ./modules

      ./modules/dev.nix
      ./modules/llm.nix
    ]
    # #
    ++ (lib.optionals isDarwin [
      ./modules/desktop.nix
      # #
    ])
    # #
    ++ (lib.optionals isLinux [
      ./modules/cosmic.nix
      # #
    ]);

    custom.cosmic.screen = "HDMI-A-1";
    custom.git.signing = {
      enable = true;
    };

    custom.firefox = {
      enable = true;
      users =
        [ ] # #
        ++ (lib.optionals isDarwin [ "karlskewes" ])
        ++ (lib.optionals isLinux [ "karl" ]);
    };

    custom.llm.claude-code = {
      enable = true;
      extraPackages = with pkgs; [ gcx ];
    };

    home.packages =
      with pkgs;
      [
        gcx

        awscli2
        aws-iam-authenticator
        az
        gdk

        kind
        kubernetes-helm

        gh
        pre-commit
        jsonnet-bundler
        yq-go
      ]
      ++ (lib.optionals isDarwin [
        podman
        podman-compose
        slack # not supported on aarch64-linux
      ])
      ++ (lib.optionals isLinux [
        asahi-bless
        asahi-btsync
        asahi-nvram
        asahi-wifisync
      ]);
  }
)

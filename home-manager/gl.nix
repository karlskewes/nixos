({ lib, pkgs, isDarwin, isLinux, ... }: {
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

  programs.bash.shellAliases = {
    dco = "docker-compose";
    k = "kubectl";
    # podman docker host export
    # https://podman-desktop.io/docs/migrating-from-docker/using-the-docker_host-environment-variable
    pdh =
      "export DOCKER_HOST=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')";
  };

  home.packages = with pkgs;
    [ ] ++ (lib.optionals isDarwin [
      google-chrome # chromium variants not supported on darwin
      slack

      awscli2
      google-cloud-sdk
      azure-cli

      docker-buildx
      podman # docker replacement
      podman-compose
      kind
      kubernetes-helm

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

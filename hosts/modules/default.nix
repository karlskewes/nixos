# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, currentStateVersion, currentSystem, currentSystemName, currentUsers
, ... }:

{
  # system user
  users = {
    mutableUsers = false;
    # for each user in currentUsers, generate users.user.${user} config.
    users = builtins.foldl' (acc: user:
      acc // {
        ${user} = {
          home = "/home/${user}";
          shell = lib.mkOverride 100 pkgs.bash;
          isNormalUser = true;
          extraGroups = [
            "audio"
            "docker"
            "scanner" # scanning
            "lp" # scanning
            "video"
            "wheel"
          ];
          # nix-shell -p mkpasswd
          # vim -> :read !mkpasswd -m sha-512
          # hashedPassword = "";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew hello@karlskewes.com"
          ];
        };
      }) { } (currentUsers);
  };

  programs.bash.enable = true;

  time.timeZone = "Australia/Brisbane";

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.memtest86.enable = {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";
    loader.efi.canTouchEfiVariables = lib.mkDefault {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (lib.hiPrio uutils-coreutils-noprefix) # rust versions
    disko
    git # can't build without it
    gnumake # gnused required for darwin only
    home-manager
    ncdu # ncdu /nix/store # find stuck old packages 'rm /tmp/nixos-rebuild.*'
    nix-diff # nix-diff /run/current-system ./result
    nvd # nix diff tool
    vim
    wget
    wireguard-tools
  ];

  fonts.fontconfig.useEmbeddedBitmaps = true;
  fonts.packages = with pkgs; [ nerd-fonts.hack font-awesome ];

  hardware.enableAllFirmware = true;

  i18n = { defaultLocale = "en_US.UTF-8"; };

  # Still problematic in 2021
  networking.enableIPv6 = false;
  networking.hostName = "${currentSystemName}";
  networking.nat.enableIPv6 = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.enable = false;
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  # Network manager required for `iwd` wifi on last check but can conflict with this.
  # However, without useDHCP=true, then an IP address may be retrieved but nameservers in /etc/resolv.conf may not be setup.
  # Set true per interface when interface is known.
  networking.useDHCP = lib.mkDefault false;
  # set network interface in ${machine}/default.nix
  # :read !ip link | grep ': en'
  # networking.interfaces.ens33.useDHCP = true;

  networking.firewall.enable =
    lib.mkDefault true; # disable for Kubernetes Kind, breaks inter-pod traffic.
  # https://nixos.org/manual/nixos/stable/options.html#opt-networking.firewall.allowedTCPPorts
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # https://nixos.org/manual/nixos/stable/options.html#opt-networking.firewall.allowedTCPPortRanges
  # networking.firewall.allowedTCPPortRanges  = [
  #  { from = 4000; to = 4007; }
  #  { from = 8000; to = 8010; }
  # ];
  # networking.firewall.allowedUDPPorts = [];
  # networking.firewall.allowedUDPPortRanges = [];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      # only allow users with sudo access ability to access nix daemon
      allowed-users = [ "@wheel" ];
      auto-optimise-store = true;
      trusted-users =
        [ "karl" "karlskewes" ]; # ability to add cache substituters.

      substituters = [
        "https://cache.nixos.org"

        # https://garnix.io/blog/stop-trusting-nix-caches
        # "https://nix-community.cachix.org"
        # "https://nixos-apple-silicon.cachix.org"
      ];
      trusted-public-keys = [
        # cache.nixos.org key built-in

        # https://garnix.io/blog/stop-trusting-nix-caches
        # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
      ];
    };

    optimise = {
      automatic = true;
      dates = [ "06:00" ];
    };

    # automatically trigger garbage collection
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 8d";
    };
  };

  security.polkit.enable = true;

  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable =
    true; # default true if above gnome-keyring enabled.
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = { main = { capslock = "overload(meta, esc)"; }; };
      };
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitch = lib.mkDefault "ignore"; # default "suspend"
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    IdleAction = "lock";
    IdleActionSec = 3600;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Let 'nixos-version --json' know about the Git revision
  # system.configurationRevision = currentRevision;

  # Docker seems to be more reliable for the containers running.
  virtualisation.docker = { enable = true; };
  virtualisation.oci-containers.backend = "docker";

  # virtualisation = {
  #   podman = {
  #     enable = true;
  #     extraPackages = [ pkgs.zfs ];
  #     dockerCompat = true;
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "${currentStateVersion}"; # Did you read the comment?
}

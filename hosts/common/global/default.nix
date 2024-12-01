# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, currentRevision, currentStateVersion, currentSystem
, currentSystemName, currentUsers, ... }:

{

  # system user
  users = {
    mutableUsers = false;
    # for each user in currentUsers, generate users.user.${user} config.
    users = builtins.foldl' (acc: user:
      acc // {
        ${user} = {
          home = "/home/${user}";
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

  time.timeZone = "Australia/Brisbane";

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.memtest86.enable = {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";
    loader.efi.canTouchEfiVariables = {
      "x86_64-linux" = true;
      "aarch64-linux" = false;
    }."${currentSystem}";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    disko
    git # can't build without it
    gnumake
    home-manager
    nix-diff # nix-diff /run/current-system ./result
    nvd # nix diff tool
    vim
    wget
    wireguard-tools
  ];

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

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # set network interface in ${machine}.nix
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

  security.sudo.wheelNeedsPassword = false;

  services.fwupd = {
    enable = true;
    extraRemotes = [ "lvfs-testing" ];
  };

  services.gnome.gnome-keyring.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = { main = { capslock = "overload(meta, esc)"; }; };
      };
    };
  };

  services.logind = {
    lidSwitch = lib.mkDefault "ignore"; # default "suspend"
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      IdleAction=lock
      IdleActionSec=3600
    '';
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

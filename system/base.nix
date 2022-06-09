# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, currentRevision, currentUser, currentSystem, currentSystemName
, ... }:

{
  # system user
  users.users.${currentUser} = {
    home = "/home/${currentUser}";
    isNormalUser = true;
    extraGroups = [ "audio" "docker" "wheel" ];
    # nix-shell -p mkpasswd
    # vim -> :read !mkpasswd -m sha-512
    # hashedPassword = "";
  };
  # Users password/etc are set from source
  users.mutableUsers = false;

  time.timeZone = "Pacific/Auckland";

  # TODO: tidy/de-dupe/other?
  boot = if currentSystem == "x86_64-linux" then {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.memtest86.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "zfs" ];
    kernelParams = [ "nohibernate" ]; # not supported by zfs
    zfs.devNodes = "/dev/disk/by-path";
    zfs.requestEncryptionCredentials = true; # prompt for encryption password
  } else if currentSystem == "aarch64-linux" then {
    loader.grub.enable = false;
    # loader.generic-extlinux-compatible.enable = true;
    loader.raspberryPi.enable = true;
    loader.raspberryPi.version = 3;
    loader.raspberryPi.uboot.enable = true;
    loader.raspberryPi.firmwareConfig = ''
      dtparam=audio=on
    '';
    consoleLogLevel = pkgs.lib.mkDefault 7;
    supportedFilesystems = [ "zfs" ];
    kernelParams = [ "console=ttyS1,115200n8" "nohibernate" ];
    kernelPackages = pkgs.linuxPackages_rpi3;
    zfs.devNodes = "/dev/disk/by-path";
    zfs.requestEncryptionCredentials = true; # prompt for encryption password
  } else
  # unknown arch, build should fail due to lack of boot.loader
    { };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git # can't build without it
    gnumake
    home-manager
    nix-diff # nix-diff /run/current-system ./result
    xclip
    vim
    wget
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  # Still problematic in 2021
  networking.enableIPv6 = false;
  networking.hostName = "${currentSystemName}";
  networking.nat.enableIPv6 = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # set network interface in ${machine}.nix
  # :read !ip link | grep ': en'
  # networking.interfaces.ens33.useDHCP = true;

  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts (https://nixos.org/manual/nixos/stable/options.html#opt-networking.firewall.allowedTCPPorts) = [ 22 ];
  # networking.firewall.allowedTCPPortRanges (https://nixos.org/manual/nixos/stable/options.html#opt-networking.firewall.allowedTCPPortRanges) = [
  #  { from = 4000; to = 4007; }
  #  { from = 8000; to = 8010; }
  # ];
  # networking.firewall.allowedUDPPorts = [];
  # networking.firewall.allowedUDPPortRanges = [];

  nix = {
    # Enable support for nix flakes - remove when `nix --version` >= 2.4
    package = pkgs.nixFlakes;
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

  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "no";

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  # Let 'nixos-version --json' know about the Git revision
  system.configurationRevision = currentRevision;

  # Virtualization settings
  # Make sure to mount ext4 partition at /var/lib/docker else Kind doesn't work.
  # TODO: check why... zfs related?
  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

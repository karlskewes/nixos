{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.zfsBootUnlock = {
    enable = lib.mkEnableOption "zfsBootUnlock";

    authorizedKeys = lib.mkOption {
      default = [ ];
      type = with lib.types; listOf str;
      description = ''
        SSH AuthorizedKeys.
      '';
    };

    interfaces = lib.mkOption {
      default = [ ];
      type = with lib.types; listOf str;
      description = ''
        Network interfaces to enable DCHP on.
      '';
    };
  };

  config = {
    assertions = lib.mkIf config.zfsBootUnlock.enable [
      {
        assertion = lib.length (config.zfsBootUnlock.authorizedKeys) > 0;
        message = "zfsBootUnlock.authorizedKeys required to login via ssh";
      }
      {
        assertion = lib.length (config.zfsBootUnlock.interfaces) > 0;
        message = "zfsBootUnlock.interfaces required to enable dhcp on";
      }
    ];

    boot = {
      # use latest supported zfs kernel - https://github.com/openzfs/zfs/releases
      kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_6_18;
      supportedFilesystems = [ "zfs" ];
      zfs.devNodes = "/dev/disk/by-path";
      zfs.forceImportRoot = false;
      zfs.requestEncryptionCredentials = true; # prompt for encryption password

      kernelParams = [
        "nohibernate" # not supported by zfs
      ]
      ++ lib.optionals config.zfsBootUnlock.enable [
        "ip=dhcp" # ssh remote unlock, works but will show warning "can't find device ip=dhcp"
      ];

      # https://nixos.wiki/wiki/ZFS#Remote_unlock
      initrd = lib.mkIf config.zfsBootUnlock.enable {
        availableKernelModules = config.zfsBootUnlock.interfaces;
        # :read !sudo lshw -C network | grep --only-matching "driver=\S*"
        network = {
          # This will use udhcp to get an ip address.
          enable = true;
          ssh = {
            enable = true;
            port = 2222;
            # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
            # the keys are copied to initrd from the path specified; multiple keys can be set
            # you can generate any number of host keys using
            # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`
            # config.zfsBootUnlock.enable must be set to false during NixOS
            # install (./run.sh install) because the host key below is not set
            # and can't be copied to initrd.
            hostKeys = [ /etc/ssh/ssh_host_ed25519_key ];
            authorizedKeys = config.zfsBootUnlock.authorizedKeys;
            # Unlock with:
            # host=<IP> ssh -p 2222 root@"${host}"
            # 🔐 Enter key for <pool>: ••••••••••••••••••
          };
        };
        # Write a .profile to /var/empty (root's home in the systemd initrd)
        # so that logging in over SSH automatically starts the password agent.
        systemd.services.zfs-setup-root-profile = {
          description = "Prepare root .profile for ZFS unlocking via SSH";
          wantedBy = [ "initrd.target" ];
          before = [ "initrd-root-fs.target" ];
          unitConfig.DefaultDependencies = false;
          script = ''
            mkdir -p /var/empty
            echo "systemd-tty-ask-password-agent --watch" > /var/empty/.profile
          '';
          serviceConfig.Type = "oneshot";
        };
      };
    };

    services.zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
      trim.enable = true;
    };

    virtualisation.docker = {
      storageDriver = lib.mkDefault "zfs";
    };
  };
}

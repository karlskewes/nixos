{ config, lib, ... }:

{
  boot = {
    kernelParams = [ "nohibernate" ]; # not supported by zfs
    supportedFilesystems = [ "zfs" ];
    zfs.devNodes = "/dev/disk/by-path";
    zfs.requestEncryptionCredentials = true; # prompt for encryption password
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
    trim.enable = true;
  };

  nixpkgs.config.allowBroken = true; # Package ‘zfs-kernel-2.2.4-6.9.9-asahi’

  virtualisation.docker = { storageDriver = lib.mkDefault "zfs"; };
}

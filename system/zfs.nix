{ config, ... }:

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

  virtualisation.docker = { storageDriver = "zfs"; };
}

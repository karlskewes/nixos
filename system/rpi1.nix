{ config, pkgs, ... }: {
  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "c3f22703";
}

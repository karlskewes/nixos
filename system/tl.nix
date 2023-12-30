{ config, pkgs, ... }: {
  imports = [
    ./base.nix
    ./i3.nix
    ./zfs.nix
  ];

  powerManagement.enable = true;

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "1014a839";
  networking.interfaces.enp1s0f0.useDHCP = true; # onboard
  networking.interfaces.enp5s0f4u1u3c2.useDHCP = true; # dock
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  # dock "displaylink" driver must be manually installed, see run.sh
  # TODO: convert to nix
  # modesetting required I think for actual display output to dock
  services.xserver.videoDrivers = [ "displaylink" "modesetting" "amdgpu" ];
  services.xserver.upscaleDefaultCursor = true; # hidpi
  services.xserver.dpi = 109;

  # defined here so LightDM is started after autorandr and thus login screen
  # shows on correct monitor.
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.autorandr}/bin/autorandr external
  '';
  services.autorandr = {
    enable = true;
    defaultTarget = "external"; # laptop lid normally shut
    profiles = {
      # list profiles with `autorandr`, switch `autorandr both`
      both = {
        config = {
          # autorandr --config
          eDP-1 = {
            enable = true;
            mode = "3840x2400";
            primary = true;
            position = "0x0";
            rate = "60.00";
            dpi = 180;
            crtc = 0;
          };
          DVI-I-1-1 = {
            enable = true;
            mode = "2560x1440";
            position = "3840x0";
            rate = "144.00";
            dpi = 109;
            crtc = 4;
          };
        };
        fingerprint = {
          # nix-shell -p autorandr
          # autorandr --fingerprint
          eDP-1 =
            "00ffffffffffff000e6f111400000000001f0104b51e1378038269ae5144af250e4f560000000101010101010101010101010101010180e800a0f0605090302036002ebd10000018000000fd00283c95953c010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030375a41312d340a20016202031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
          DVI-I-1-1 =
            "00ffffffffffff005a6338a76e040000211e0103803c22782e9f00ad4f44ac270d5054bfef80d1c08140818090409500a940b300a9c09ee00078a0a032501040350056502100001e000000fd0030921ef03c000a202020202020000000fc005658323735382d536572696573000000ff005656463230333330313133340a0119020337f151010304050790121314161f2021223f404e230907078301000067030c002000383c67d85dc401788000681a000001013092edf5bd00a0a0a032502040450056502100001e023a801871382d403020360056502100001ef97e8088703812401820350056502100001e565e00a0a0a029503020350056502100001eb7";
        };
      };
      external = {
        config = {
          "eDP-1".enable = false;
          DVI-I-1-1 = {
            enable = true;
            mode = "2560x1440";
            position = "0x0";
            primary = true;
            rate = "144.00";
            dpi = 109;
            crtc = 4;
          };
        };
        fingerprint = {
          eDP-1 =
            "00ffffffffffff000e6f111400000000001f0104b51e1378038269ae5144af250e4f560000000101010101010101010101010101010180e800a0f0605090302036002ebd10000018000000fd00283c95953c010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030375a41312d340a20016202031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
          DVI-I-1-1 =
            "00ffffffffffff005a6338a76e040000211e0103803c22782e9f00ad4f44ac270d5054bfef80d1c08140818090409500a940b300a9c09ee00078a0a032501040350056502100001e000000fd0030921ef03c000a202020202020000000fc005658323735382d536572696573000000ff005656463230333330313133340a0119020337f151010304050790121314161f2021223f404e230907078301000067030c002000383c67d85dc401788000681a000001013092edf5bd00a0a0a032502040450056502100001e023a801871382d403020360056502100001ef97e8088703812401820350056502100001e565e00a0a0a029503020350056502100001eb7";
        };
      };
      primary = {
        config = {
          eDP-1 = {
            enable = true;
            mode = "3840x2400";
            position = "0x0";
            primary = true;
            rate = "60.00";
            dpi = 180;
            crtc = 0;
          };
        };
        fingerprint = {
          eDP-1 =
            "00ffffffffffff000e6f111400000000001f0104b51e1378038269ae5144af250e4f560000000101010101010101010101010101010180e800a0f0605090302036002ebd10000018000000fd00283c95953c010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030375a41312d340a20016202031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
        };
      };
    };
  };
  services = {
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
  };

  # TODO: check now that pipewire enabled
  # Need full for bluetooth support
  # hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # required to use dvd/cdrom in some applications
  programs.dconf.enable = true;
}

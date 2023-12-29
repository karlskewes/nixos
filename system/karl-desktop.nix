{ config, pkgs, ... }: {

  imports = [
    ./base.nix
    ./xserver.nix
    ./libvirtd.nix
    ./zfs.nix
  ];

  # Define hostId for zfs pool machine 'binding'
  # :read !head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "f299660e";
  networking.interfaces.enp9s0.useDHCP = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  services = {
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
  };

  # defined here so LightDM is started after autorandr and thus login screen
  # shows on correct monitor.
  # services.xserver.displayManager.setupCommands = ''
  # ${pkgs.autorandr}/bin/autorandr primary
  # '';
  services.autorandr = {
    enable = true;
    defaultTarget = "primary";
    profiles = {
      # list profiles with `autorandr`, switch `autorandr both`
      both = {
        config = {
          # autorandr --config
          HDMI-A-0 = {
            enable = true;
            mode = "1920x1080";
            position = "0x0";
            rate = "60.00";
            dpi = 109;
            crtc = 1;
          };
          DisplayPort-2 = {
            enable = true;
            mode = "2560x1440";
            primary = true;
            position = "1920x1080";
            rate = "144.00";
            dpi = 109;
            crtc = 0;
          };
        };
        fingerprint = {
          # nix-shell -p autorandr
          # autorandr --fingerprint
          DisplayPort-2 =
            "00ffffffffffff005a6338a700000000211e0104b53c22783f9f00ad4f44ac270d5054bfef80d1c08140818090409500a940b300a9c09ee00078a0a032501040350056502100001e000000fd003092f0f03c010a202020202020000000fc005658323735382d536572696573000000ff005656463230333330313133340a0171020323f150010304050790121314161f2021223f40230907078301000065030c001000f5bd00a0a0a032502040450056502100001e023a801871382d403020360056502100001efa7e8088703812401820350056502100001e565e00a0a0a029503020350056502100001e00000000000000000000000000000000000000002b";
          HDMI-A-0 =
            "00ffffffffffff0010ac98a0424a30342b18010380301b78eaebf5a656519c26105054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c4500dd0c1100001e000000ff0048574e473734414f34304a420a000000fc0044454c4c205032323134480a20000000fd00384c1e5311000a20202020202000d0";
        };
      };
      left = {
        config = {
          "DisplayPort-2".enable = false;
          HDMI-A-0 = {
            enable = true;
            mode = "1920x1080";
            position = "0x0";
            primary = true;
            rate = "60.00";
            dpi = 109;
            crtc = 0;
          };
        };
        fingerprint = {
          DisplayPort-2 =
            "00ffffffffffff005a6338a700000000211e0104b53c22783f9f00ad4f44ac270d5054bfef80d1c08140818090409500a940b300a9c09ee00078a0a032501040350056502100001e000000fd003092f0f03c010a202020202020000000fc005658323735382d536572696573000000ff005656463230333330313133340a0171020323f150010304050790121314161f2021223f40230907078301000065030c001000f5bd00a0a0a032502040450056502100001e023a801871382d403020360056502100001efa7e8088703812401820350056502100001e565e00a0a0a029503020350056502100001e00000000000000000000000000000000000000002b";
          HDMI-A-0 =
            "00ffffffffffff0010ac98a0424a30342b18010380301b78eaebf5a656519c26105054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c4500dd0c1100001e000000ff0048574e473734414f34304a420a000000fc0044454c4c205032323134480a20000000fd00384c1e5311000a20202020202000d0";
        };
      };
      primary = {
        config = {
          DisplayPort-2 = {
            enable = true;
            mode = "2560x1440";
            position = "0x0";
            primary = true;
            rate = "144.00";
            dpi = 109;
            crtc = 0;
          };
          "HDMI-A-0".enable = false;
        };
        fingerprint = {
          DisplayPort-2 =
            "00ffffffffffff005a6338a700000000211e0104b53c22783f9f00ad4f44ac270d5054bfef80d1c08140818090409500a940b300a9c09ee00078a0a032501040350056502100001e000000fd003092f0f03c010a202020202020000000fc005658323735382d536572696573000000ff005656463230333330313133340a0171020323f150010304050790121314161f2021223f40230907078301000065030c001000f5bd00a0a0a032502040450056502100001e023a801871382d403020360056502100001efa7e8088703812401820350056502100001e565e00a0a0a029503020350056502100001e00000000000000000000000000000000000000002b";
          HDMI-A-0 =
            "00ffffffffffff0010ac98a0424a30342b18010380301b78eaebf5a656519c26105054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c4500dd0c1100001e000000ff0048574e473734414f34304a420a000000fc0044454c4c205032323134480a20000000fd00384c1e5311000a20202020202000d0";
        };
      };
    };
  };

  # required to use dvd/cdrom in some applications
  programs.dconf.enable = true;
}

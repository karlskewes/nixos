# NixOS

TODO: Read docs again and figure out better pattern with imports/overlays/overrides/flakes?
for composition - per machine config.

## Bootstrap VM

1. Install vmware fusion
1. vmware Preferences
   1. Keyboard → Mac Profile
      Restore MSFT keyboard mappings - assuming MacOS Keyboard Command/Option swapped
      1. Command → Alt
      1. Option → Win
   1. General → Mouse always optimize for gaming (otherwise scroll speed too slow!)
1. vmware Virtual Camera (sharing) disable - https://kb.vmware.com/s/article/2145940
   1. `echo 'vusbcamera.passthrough = "TRUE"' >>  ~/Library/Preferences/VMware\ Fusion/preferences` 
   1. quit and restart vmware
1. download minimal iso https://nixos.org/download.html#nixos-iso
1. create vm in vmware fusion
    1. UEFI - not sure if necessary but ok
    1. Sharing → ?? *TODO*
    1. Processors and Memory → 8T & 32GB
    1. Display → Use full resolution & hardware acceleration all the time - Max (8GB) video memory
    1. Network → NAT or Bridge
    1. Add Device → hard disk - 100GB - save as user-device-nixos.vmdk
    1. USB & Bluetooth → USB 3.1 - required for Logitech Camera & acceptable cpu in Google Meet
    1. Isolation → Both ticked
1. vmware mouse fix side buttons and scoll skips - https://communities.vmware.com/t5/VMware-Fusion-Discussions/Mouse-wheel-scrolling-skips-clicks/td-p/463246
   ```
   cat <<EOF >> ~/Virtual\ Machines.localized/karl-mac-nixos.vmwarevm/karl-mac-nixos.vmx
   mouse.vusb.enable = "TRUE"
   mouse.vusb.useBasicMouse = "FALSE"
   usb.generic.allowHID = "TRUE"
   mks.mouse.pixelScrollSensitivity = 1
   EOF
   ```
1. boot VM
1. Setup per https://nixos.org/manual/nixos/stable/index.html#sec-installation-summary
    1. `git clone git@github.com:kskewes/nixos.git`
    1. `cd nixos && ./bootstrap-vm.sh`
    1. `sudo reboot`

## Configure home-manager (user)

1. Login using graphical interface
1. Open terminal
1. `git clone git@github.com:kskewes/nixos.git`
1. `cd nixos && ./configure-home-manager.sh`

## updates

System:
```
nixos-rebuild switch -I nixos-config=./nixos/configuration.nix
```

### user

```
# or other file
vim base.nix
home-manager switch -f ./home-manager/base.nix
```

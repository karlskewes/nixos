# NixOS

TODO: Read docs again and figure out better pattern with imports/overlays/overrides/flakes?
for composition - per machine config.

## Bootstrap VM

1. Install vmware fusion
1. Vmware Preferences → Keyboard → Mac Profile
    Restore MSFT keyboard mappings - assuming MacOS Keyboard Command/Option swapped
    1. Command → Alt
    1. Option → Win
1. download minimal iso https://nixos.org/download.html#nixos-iso
1. create vm in vmware fusion
    1. UEFI - not sure if necessary but ok
    1. Sharing → ?? *TODO*
    1. Processors and Memory → 8T & 32GB
    1. Display → Use full resolution & hardware acceleration all the time - Max (8GB) video memory
    1. Network → NAT
    1. Add Device → hard disk - 100GB - save as user-device-nixos.vmdk
    1. Isolation → Both ticked
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

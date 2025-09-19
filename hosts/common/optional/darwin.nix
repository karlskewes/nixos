{ lib, pkgs, currentSystem, currentUsers, ... }: {
  nixpkgs.config.allowUnfree = lib.mkDefault true;
  nixpkgs.hostPlatform = currentSystem;
  nix.settings.experimental-features = "nix-command flakes";
  ids.gids.nixbld = 350; # Default in newer installations.
  # ids.gids.nixbld = 30000; # karl-mba - old installations.
  system.primaryUser = "karlskewes"; # TODO: pull from currentUsers?

  # Declare the user that will be running `nix-darwin`.
  users.users = builtins.foldl' (acc: user:
    acc // {
      ${user} = {
        name = "${user}";
        home = "/Users/${user}";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew hello@karlskewes.com"
        ];
        shell = pkgs.bash; # $ chsh -s /run/current-system/sw/bin/bash
      };
    }) { } (currentUsers);

  environment.shells = [ pkgs.bashInteractive pkgs.zsh ];
  programs.bash.enable = true;
  programs.bash.completion.enable = true;
  programs.zsh.enable = true;

  environment.shellAliases = { l = "ls -lah"; };

  environment.systemPackages = with pkgs; [
    watch # not included in darwin.
    (pkgs.hiPrio uutils-coreutils-noprefix) # rust versions
  ];

  networking.applicationFirewall.enable = true;
  networking.applicationFirewall.blockAllIncoming = false; # default
  networking.applicationFirewall.enableStealthMode = false; # default

  nix.gc.automatic = true;
  nix.gc.interval = [{
    Hour = 7;
    Minute = 30;
    Weekday = 7;
  }];
  nix.optimise.automatic = true;

  services.aerospace = {
    enable = true;
    settings = {
      gaps = {
        inner.horizontal = 2;
        inner.vertical = 2;
        outer.left = 4;
        outer.bottom = 4;
        outer.top = 4;
        outer.right = 4;
      };

      # 'main' binding mode declaration
      # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
      # 'main' binding mode must be always presented
      # Fallback value (if you omit the key): mode.main.binding = {}
      mode.main.binding = {
        # TODO: copy Cosmic desktop.
        # See: https://nikitabobko.github.io/AeroSpace/commands#focus

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        # See: https://nikitabobko.github.io/AeroSpace/commands#move
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";

        # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
        alt-tab = "workspace-back-and-forth";
        # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
      };

      # aerospace list-apps --json
      on-window-detected = [
        {
          "if" = { app-id = "net.kovidgoyal.kitty"; };
          run = [ "move-node-to-workspace 1" ];
        }
        {
          "if" = { app-id = "org.nixos.firefox"; };
          run = [ "move-node-to-workspace 2" ];
        }
        {
          "if" = {
            app-id = "com.tinyspeck.slackmacgap";
            app-name-regex-substring = "slack";
          };
          run = [ "move-node-to-workspace 3" ];
        }
      ];
    };
  };

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
  };

  system.startup.chime = false;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  # TODO: control and command to match NixOS?
  # system.keyboard.userKeyMapping = [
  #   { # LeftCtrl to LeftCommand
  #     HIDKeyboardModifierMappingSrc = 30064771299;
  #     HIDKeyboardModifierMappingDst = 30064771296;
  #   }
  #   { # LeftCommand to LeftCtrl
  #     HIDKeyboardModifierMappingSrc = 30064771296;
  #     HIDKeyboardModifierMappingDst = 30064771299;
  #   }
  # ];

  system.stateVersion = 5;
}

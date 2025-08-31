{ lib, pkgs, currentSystem, currentUsers, ... }: {
  nixpkgs.config.allowUnfree = lib.mkDefault true;
  nixpkgs.hostPlatform = currentSystem;
  nix.settings.experimental-features = "nix-command flakes";
  ids.gids.nixbld = 30000; # 350 # Default in newer installations.
  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
  };

  # Declare the user that will be running `nix-darwin`.
  users.users = builtins.foldl' (acc: user:
    acc // {
      ${user} = {
        name = "${user}";
        home = "/Users/${user}";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHa6kemH+dg/qistkK0BRME83j+uhN50ckV7DwyfXew hello@karlskewes.com"
        ];
        shell = pkgs.bash; # $ chsh -s /run/current-system/sw/bin/fish
      };
    }) { } (currentUsers);

  environment.shells = [ pkgs.bashInteractive pkgs.fish pkgs.zsh ];
  programs.bash.enable = true;
  programs.fish.enable = true;
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs;
    [
      (pkgs.hiPrio uutils-coreutils-noprefix) # rust versions
    ];

  system.stateVersion = 5;
}

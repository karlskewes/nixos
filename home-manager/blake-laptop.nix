({ pkgs, ... }: {
  # TODO: multiple users
  imports = [
    ./user-karl.nix

    ./modules

    ./modules/cosmic.nix
  ];

  custom.firefox = {
    enable = true;
    users = [ "blake" "karl" ];
  };

  home.packages = with pkgs; [ ];
})

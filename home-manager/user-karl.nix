{ config, lib, pkgs, currentStateVersion, ... }:

let user = "karl";
in {
  imports = [ ./dev.nix ];

  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "${currentStateVersion}";

  programs.bash = {
    enable = true;

    initExtra = ''
      # https://github.com/nix-community/home-manager/issues/1011
      # https://nix-community.github.io/home-manager/index.html#_why_are_the_session_variables_not_set
      # source our session variables otherwise not used in x sessions
      if [[ -f "/etc/profiles/per-user/${user}/etc/profile.d/hm-session-vars.sh" ]]; then
        source "/etc/profiles/per-user/${user}/etc/profile.d/hm-session-vars.sh"
      fi
      if [[ -f "/home/${user}/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
        source "/home/${user}/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi
    '';
  };
  programs.git = {
    enable = true;
    userName = "Karl Skewes";
    userEmail = lib.mkDefault "hello@karlskewes.com";
    extraConfig = {
      url = {
        "ssh://git@github.com/karlskewes/" = {
          insteadOf = "https://github.com/karlskewes/";
        };
      };
    };
  };
}

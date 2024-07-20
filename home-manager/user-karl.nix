{ config, lib, pkgs, currentStateVersion, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  user = if isLinux then "karl" else "karlskewes";
  homeDir = if isLinux then "/home/${user}" else "/Users/${user}";
in {
  imports = [ ];

  home.username = "${user}";
  home.homeDirectory = homeDir;
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
      if [[ -f "${homeDir}/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
        source "${homeDir}/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "Karl Skewes";
    userEmail = lib.mkDefault "hello@karlskewes.com";
    signing.key = lib.mkDefault "8A391F56B7EE82DA";
    signing.signByDefault = lib.mkDefault true;
    extraConfig.url = lib.mkDefault {
      "ssh://git@github.com/karlskewes/" = {
        insteadOf = "https://github.com/karlskewes/";
      };
    };
  };
}

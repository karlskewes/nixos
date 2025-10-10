{ config, lib, currentStateVersion, isDarwin, ... }:

let
  user = if isDarwin then "karlskewes" else "karl";
  homeDir = if isDarwin then "/Users/${user}" else "/home/${user}";
in {
  imports = [ ];

  home.username = "${user}";
  home.homeDirectory = homeDir;
  home.stateVersion = "${currentStateVersion}";

  desktop.firefox.users = [ "${user}" ];

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
    # If we're signing then we have a key required to fetch via SSH, otherwise stick with HTTPS
    # so public repositories can still be fetched.
    extraConfig.url."ssh://git@github.com/karlskewes/" =
      lib.mkIf config.common.git.signing.enable {
        insteadOf = "https://github.com/karlskewes/";
      };
    # go get repo@branch can also get confused and fail. Force to SSH.
    extraConfig.url."ssh://git@github.com/" =
      lib.mkIf config.common.git.signing.enable {
        insteadOf = "https://github.com/";
      };
  };
}

{ config
, lib
, pkgs
, currentStateVersion
, ...
}:

{
  imports = [
    ./dev.nix
  ];

  home.username = "karl";
  home.homeDirectory = "/home/karl";
  home.stateVersion = "${currentStateVersion}";

  programs.bash = {
    enable = true;

    # TODO: make this generic?
    initExtra = ''
      # https://github.com/nix-community/home-manager/issues/1011
      # https://nix-community.github.io/home-manager/index.html#_why_are_the_session_variables_not_set
      # source our session variables otherwise not used in x sessions
      if [[ -f "/etc/profiles/per-user/karl/etc/profile.d/hm-session-vars.sh" ]]; then
        source "/etc/profiles/per-user/karl/etc/profile.d/hm-session-vars.sh"
      fi
      if [[ -f "/home/karl/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
        source "/home/karl/.nix-profile/etc/profile.d/hm-session-vars.sh"
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

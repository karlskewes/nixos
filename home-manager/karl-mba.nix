({ lib, pkgs, isDarwin, isLinux, ... }: {
  imports = [
    ./user-karl.nix

    ./common/global

    ./common/optional/dev.nix
    ./common/optional/gpg.nix
  ] # #
    ++ (lib.optionals isDarwin [ ])
    # #
    ++ (lib.optionals isLinux [
      ./common/optional/cosmic.nix
      # #
    ]);

  common.git.signing = { enable = true; };

  desktop.firefox = { enable = true; };

  home.packages = with pkgs;
    [ ] ++ (lib.optionals isDarwin [
      podman # docker replacement
      podman-compose
    ]) ++ (lib.optionals isLinux [
      asahi-bless
      asahi-btsync
      asahi-nvram
      asahi-wifisync

      # calibre # 7.26.0 broken errors during test_piper, re-add when fixed.
    ]);

  # IRC client via ZNC IRC bouncer - https://halloy.chat/configuration/servers.html
  programs.halloy = {
    enable = true;
    settings = {
      buffer.channel.topic = { enabled = true; };
      buffer.server_messages = {
        join.enabled = false;
        part.enabled = false;
        quit.enabled = false;
        topic.enabled = false;
      };
      font.size = 16; # default 13 bit small.
      servers.oftc = {
        channels =
          [ "#asahi" "#asahi-alt" "#asahi-dev" "asahi-gpu" "asahi-re" ];
        nickname = "k70";
        alt_nicks = [ "k70_" "k70__" ];
        username = "karl";
        password_file = "~/.config/halloy/pfile";
        server = "tiny";
        port = 16667;
        use_tls = false;
      };
      actions.buffer = {
        click_channel_name = "replace-pane";
        click_highlight = "replace-pane";
        click_username = "replace-pane";
        local = "replace-pane";
        message_channel = "replace-pane";
        message_user = "replace-pane";
      };
      actions.sidebar = { buffer = "replace-pane"; };

    };
  };
})


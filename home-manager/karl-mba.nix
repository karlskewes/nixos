(
  {
    lib,
    pkgs,
    isDarwin,
    isLinux,
    ...
  }:
  {
    imports = [
      ./user-karl.nix
      ./modules

      ./modules/dev.nix
    ]
    # #
    ++ (lib.optionals isDarwin [
      ./modules/desktop.nix
      # #
    ])
    ++ (lib.optionals isLinux [
      ./modules/cosmic.nix
      # #
    ]);

    custom.git.signing = {
      enable = true;
    };

    custom.firefox = {
      enable = true;
      users =
        [ ] # #
        ++ (lib.optionals isDarwin [ "karlskewes" ])
        ++ (lib.optionals isLinux [ "karl" ]);
    };

    home.packages =
      with pkgs;
      [ ]
      ++ (lib.optionals isDarwin [
        podman # docker replacement
        podman-compose
      ])
      ++ (lib.optionals isLinux [
        asahi-bless
        asahi-btsync
        asahi-nvram
        asahi-wifisync

        # calibre # 7.26.0 broken errors during test_piper, re-add when fixed.
      ]);

    # https://github.com/catppuccin/halloy/blob/main/themes/catppuccin-mocha.toml
    home.file.".config/halloy/themes/catppuccin-mocha.toml" = {
      text = ''
        [general]
        background = "#11111b"
        border = "#6c7086"
        horizontal_rule = "#313244"
        unread_indicator = "#cba6f7"

        [text]
        primary = "#cdd6f4"
        secondary = "#a6adc8"
        tertiary = "#cba6f7"
        success = "#a6e3a1"
        error = "#f38ba8"

        [buttons.primary]
        background = "#11111b"
        background_hover = "#181825"
        background_selected = "#1e1e2e"
        background_selected_hover = "#181825"

        [buttons.secondary]
        background = "#181825"
        background_hover = "#45475a"
        background_selected = "#313244"
        background_selected_hover = "#45475a"

        [buffer]
        action = "#fab387"
        background = "#1e1e2e"
        background_text_input = "#181825"
        background_title_bar = "#181825"
        border = "#11111b"
        border_selected = "#b4befe"
        code = "#b4befe"
        highlight = "#45475a"
        nickname = "#89dceb"
        selection = "#313244"
        timestamp = "#bac2de"
        topic = "#7f849c"
        url = "#89b4fa"

        [buffer.server_messages]
        default = "#f9e2af"
      '';
    };

    # IRC client via ZNC IRC bouncer - https://halloy.chat/configuration/servers.html
    programs.halloy = {
      enable = true;
      settings = {
        theme = "catppuccin-mocha";
        buffer.channel.topic = {
          enabled = true;
        };
        buffer.nickname = {
          away = "none"; # otherwise away usernames too faint to read.
          brackets = {
            left = "<";
            right = ">";
          };
        };
        buffer.server_messages = {
          join.enabled = false;
          part.enabled = false;
          quit.enabled = false;
          topic.enabled = false;
        };
        font.size = 16; # default 13 bit small.
        servers.oftc = {
          channels = [
            "#asahi"
            "#asahi-alt"
            "#asahi-dev"
            "asahi-gpu"
            "asahi-re"
          ];
          nickname = "k70";
          alt_nicks = [
            "k70_"
            "k70__"
          ];
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
        actions.sidebar = {
          buffer = "replace-pane";
        };

      };
    };
  }
)

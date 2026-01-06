# X Windows additional configuration dependent on home-manager
{ config, lib, pkgs, isDarwin, isLinux, ... }: {
  options.custom.firefox = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    xdg.configFile."discord/settings.json".text = ''
      {
        "BACKGROUND_COLOR": "#202225",
        "SKIP_HOST_UPDATE": true
      }
    '';
    xdg.mime.enable = isLinux;
    xdg.portal = {
      enable = isLinux;
      xdgOpenUsePortal = true;
      config = {
        cosmic = {
          default = [ "cosmic" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
        hyprland = {
          default = [ "hyprland" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      };
    };

    fonts.fontconfig.enable = true;

    home.packages = with pkgs;
      (lib.optionals isDarwin [
        # on Linux these are installed in host/NixOS configuration.
        nerd-fonts.hack
        font-awesome
        # #
      ]) ++ (lib.optionals isLinux [
        mesa-demos
        vulkan-tools # vulkan-info
        helvum # pipewire patch bay gui

        ente-auth
        kdePackages.gwenview # image viewer & editor (crop, resize)
        vlc
      ]) ++ [
        adwaita-qt
        adwaita-icon-theme

        nerd-fonts.hack
        font-awesome

        libnotify # required by dunst
        qalculate-gtk # calculator
        # servo # rust web browser # TODO: make / larger.
      ];

    programs.firefox = lib.mkIf config.custom.firefox.enable {
      # package = pkgs.firefox;
      package = if isDarwin then
      # https://github.com/NixOS/nixpkgs/issues/451884
        pkgs.firefox.overrideAttrs (_: { gtk_modules = [ ]; })
      else
        pkgs.firefox;

      enable = true;
      # Check about:policies#documentation for options.
      # https://mozilla.github.io/policy-templates/
      policies = {
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        Preferences = { # `profiles.<name>.settings` for all profiles
          "browser.search.region" = "AU";
          # "browser.contentblocking.category" = "strict";
          "browser.topsites.contile.enabled" = false;
          "browser.formfill.enable" = false;
          "browser.search.suggest.enabled" = false;
          "browser.search.suggest.enabled.private" = false;
          "browser.urlbar.suggest.calculator" = true;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.showSearchSuggestionsFirst" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" =
            false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.system.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          # scrollbars are sometimes so small it's hard to see them and where on page.
          "layout.css.scrollbar-width-thin.disabled" = true;
          # scroll bars aren't shown when page is scrollable until move mouse,
          # and then they disappear again. Subject to change given 'testing' namespacing?
          "layout.testing.overlay-scrollbars.always-visible" = true;
          # Settings -> Browsing -> "Always show scrollbars" -> ticked. Unusual setting name though.
          "widget.gtk.overlay-scrollbars.enabled" = false;
          # link previews on long press and right click are not helpful.
          "browser.ml.linkPreview.enabled" = false;
        };
        # SearchEngines = []; # Doesn't work even with pkgs.firefox-esr.
      };
      # Check about:config for options.

      profiles = builtins.listToAttrs (lib.imap0 (i: user:
        lib.nameValuePair "${user}" {
          id = i;
          name = "${user}";
          path = "${user}";
          isDefault = if i == 0 then true else false;
          search = {
            force = true;
            default = "ddg";
            order = [ "ddg" ];
            engines = {
              "Nix Options" = {
                urls = [{
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }];
                icon =
                  "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@no" ];
              };
              "Nix Packages" = {
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }];
                icon =
                  "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              "NixOS Wiki" = {
                urls = [{
                  template =
                    "https://nixos.wiki/index.php?search={searchTerms}";
                }];
                icon = "https://nixos.wiki/favicon.png";
                updateInterval = 24 * 60 * 60 * 1000; # every day
                definedAliases = [ "@nw" ];
              };
            };
          };
        }) config.custom.firefox.users);
    };

    programs.kitty = {
      enable = true;
      font.name = "Hack Nerd Font Mono";
      settings = { enable_audio_bell = false; };
      extraConfig = ''
        map ctrl+shift+enter new_window_with_cwd
        tab_title_template "{tab.active_wd.split('/')[-1]}: {title}"
      '';
    };

    services.dunst = { enable = isLinux; };
  };
}

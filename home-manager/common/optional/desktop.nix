# X Windows additional configuration dependent on home-manager
{ config, lib, pkgs, ... }: {
  options.desktop.firefox = {
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
    xdg.mime.enable = true;
    xdg.portal = {
      enable = true;
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

    home.packages = with pkgs; [
      adwaita-qt
      adwaita-icon-theme

      glxinfo
      vulkan-tools # vulkan-info

      nerd-fonts.hack
      font-awesome

      ente-auth
      kdePackages.gwenview # image viewer & editor (crop, resize)
      helvum # pipewire patch bay gui
      libnotify # required by dunst
      qalculate-gtk # calculator
      servo # rust web browser
      vlc
    ];

    programs.firefox = lib.mkIf config.desktop.firefox.enable {
      package = pkgs.firefox;
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
        }) config.desktop.firefox.users);
    };

    programs.kitty = {
      enable = true;
      font.name = "Hack Nerd Font";
      settings = { enable_audio_bell = false; };
      extraConfig = ''
        map ctrl+shift+enter new_window_with_cwd
        tab_title_template "{tab.active_wd.split('/')[-1]}: {title}"
      '';
    };

    services.dunst = { enable = true; };
  };
}

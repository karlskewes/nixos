{ config, lib, pkgs, currentSystem, isDarwin, isLinux, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";

  # manage XDG directories
  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = with pkgs;
    (lib.optionals isDarwin [ ]) ++ (lib.optionals isLinux [
      lshw
      psmisc
      usbutils
      brightnessctl
      alsa-utils
      iptraf-ng
    ]) ++ [
      dnsutils
      pciutils

      # abcde # abcde -a cddb,read,encode,tag,move,playlist,clean,getalbumart -d /dev/cdrom -o mp3:-b320
      # easytag # requires configuration.nix 'programs.dconf.enable = true;'
      fatsort # fat32 file on disk sorter

      fd
      file
      gron # sed'able json
      zenith # htop replacement
      jq
      libqalculate # qalc - CLI calculator
      lsof
      nixfmt-classic
      nix-diff # nix-diff /run/current-system ./result
      nvd # nix diff tool
      rename
      renameutils # qmv - vim like bulk rename
      ripgrep
      rpl
      sshfs # android phone SimpleSSHD
      tcpdump
      tree
      unzip
      zip

      # https://nixos.wiki/wiki/Packaging/Binaries
      # file path/to/broken/file
      # ldd path/to/broken/file
      # Can patch interpreter for downloaded binary to the same interpeter used
      # by NixOS built package (which has correct interpreter set).
      # patchelf --set-interpreter $(patchelf --print-interpreter $(which cp)) path/to/broken/file
      patchelf
    ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less --ignore-case --hilite-unread --silent";
    MANPAGER = "less --ignore-case --hilite-unread --silent";
  };
  home.sessionPath = [
    "$HOME/.local/bin" # tools
    "$HOME/go/bin" # golang
  ];

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  imports = [ ./neovim.nix ];

  programs.bash = {
    enable = true;

    initExtra = ''
      # start daemon to connect to existing logged in session. Normally done by window manager.
      # /run/wrappers/bin/gnome-keyring-daemon --start --daemonize
      # tell ssh to use gnome keyring instead of gpg agent.
      export SSH_AUTH_SOCK=/run/user/"$UID"/keyring/ssh

      # Case-insensitive globbing (used in pathname expansion)
      shopt -s nocaseglob

      # Append to the Bash history file, rather than overwriting it
      shopt -s histappend

      # Autocorrect typos in path names when using `cd`
      shopt -s cdspell

      ${builtins.readFile ../../../dotfiles/functions.sh}

      ${builtins.readFile ../../../dotfiles/bash_prompt.sh}
    '';

    # TODO: enable merging this dict from display manager.
    shellAliases = {
      # Enable aliases to be run with sudo
      sudo = "sudo ";

      # One less char.
      v = "nvim";

      # Easier navigation: .., ..., ...., ....., ~ and -
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      # Kitty Terminal inline image viewer kitten (plugin) icat
      icat = "kitty +kitten icat";

      # IP addresses
      pubip = "dig +short myip.opendns.com @resolver1.opendns.com";
      localip =
        "sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'";
      ips =
        "sudo ip add | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'";
    };
  };

  programs.bat = {
    enable = true;
    config = {
      style = "plain";
      theme = "catppuccin";
      pager = "less --RAW-CONTROL-CHARS --ignore-case --hilite-unread --silent";
    };
    themes = {
      catppuccin = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "d714cc1d358ea51bfc02550dabab693f70cccea0";
          # nix-shell -p nix-prefetch
          # nix-prefetch --option extra-experimental-features flakes fetchFromGitHub --owner catppuccin --repo bat --rev d714cc1d358ea51bfc02550dabab693f70cccea0
          sha256 = "sha256-Q5B4NDrfCIK3UAMs94vdXnR42k4AXCqZz6sRn8bzmf4=";
        };
        file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
  };

  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    ];
    fileWidgetOptions =
      [ "--preview 'bat --color=always --style=numbers --line-range=:500 {}'" ];
  };

  programs.git = {
    enable = true;

    aliases = {
      bd = ''
        !f() {
          local curbr;
          curbr=$(git rev-parse --abbrev-ref HEAD);
          if [ "$curbr" == "main" ] || [ "$curbr" == "master" ]; then
            echo "WARNING: won't delete '$curbr' branch";
          else
            git checkout main && git branch -D $curbr;
          fi;
        }; f
      '';
      co = "checkout";
      cob = "checkout -b";
      # https://github.com/junegunn/fzf/wiki/examples#git
      cof = ''
        !f() {
          local branches branch;
          branches=$(git --no-pager branch -vv);
          branch=$(echo "$branches" | fzf +m);
          git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //");
        }; f
      '';
      com = "checkout main";
      coms = "checkout master";
      c = "commit";
      ca = "commit --amend";
      caa = "commit --amend --all";
      cf = "commit --fixup";
      cm = "commit --message";
      d = "diff";
      fup = "fetch upstream";
      fuppr =
        "!f() { git fetch upstream pull/\${1}/head:pr\${1}; git checkout pr\${1}; }; f";
      fopr =
        "!f() { git fetch origin pull/\${1}/head:pr\${1}; git checkout pr\${1}; }; f";
      lg = ''
        !f() {
          git log \
          --color \
          --graph \
          --abbrev-commit \
          --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset';
        }; f
      '';
      mupm = "merge upstream/main";
      mupms = "merge upstream/master";
      pr = "pull --rebase";
      pf = "push --force-with-lease";
      rba = "rebase --abort";
      rbc = "rebase --continue";
      rbi = "rebase --interactive";
      rbim = "rebase --interactive main";
      rbims = "rebase --interactive master";
      rbm = "rebase main";
      rbms = "rebase master";
      rbupm = "rebase upstream/main";
      rbupms = "rebase upstream/master";
      raup = "remote add upstream";
      s = "status";
    };

    extraConfig = {
      branch.sort = "committerdate";
      commit.verbose = "true";
      diff.algorithm = "histogram";
      diff.colorMoved = "plain";
      diff.mnemonicPrefix = "true";
      diff.renames = "true";
      fetch.prune = "true";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      pull.rebase = "true";
      push.default = "current";
      push.autoSetupRemote = "true";
      rebase.autosquash = "true";
      rebase.autostash = "true";
      rebase.updateRefs = # sometimes not helpful but at least you can delete from commit list.
        "true"; # https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/
      tag.sort = "version:refname";
    };
  };

  programs.readline = {
    enable = true;
    extraConfig = ''
      # Make Tab autocomplete regardless of filename case
      set completion-ignore-case on

      # List all matches in case multiple possible completions are possible
      set show-all-if-ambiguous on

      # Immediately add a trailing slash when autocompleting symlinks to directories
      set mark-symlinked-directories on

      # Use the text that has already been typed as the prefix for searching through
      # commands (i.e. more intelligent Up/Down behavior)
      "\e[B": history-search-forward
      "\e[A": history-search-backward

      # Do not autocomplete hidden files unless the pattern explicitly begins with a dot
      set match-hidden-files off

      # Show all autocomplete results at once
      set page-completions off

      # Be more intelligent when autocompleting by also looking at the text after
      # the cursor. For example, when the current line is "cd ~/src/mozil", and
      # the cursor is on the "z", pressing Tab will not autocomplete it to "cd
      # ~/src/mozillail", but to "cd ~/src/mozilla". (This is supported by the
      # Readline used by Bash 4.)
      set skip-completed-text on
    '';
  };

  # z - jump rust replacement
  programs.zoxide = { enable = true; };

}

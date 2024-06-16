{ config, lib, pkgs, currentSystem, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";

  # manage XDG directories
  xdg.enable = true;
  xdg.configFile."nvim" = {
    source = ../dotfiles/nvim;
    recursive = true;
  };
  # run `vale sync` after fresh install to create `~/styles` directory.
  # https://github.com/errata-ai/vale/issues/211
  home.file.".vale.ini" = { source = ../dotfiles/vale.ini; };

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = with pkgs;
    (lib.optionals isDarwin [ ]) ++ (lib.optionals isLinux [
      psmisc
      usbutils
      brightnessctl
      alsa-utils

      gnome.seahorse
      pinentry # gpg add ssh key
      # export GPG_TTY=$(tty)
      # export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      # gpg ssh-add -c -t 31536000 path/to/id_rsa

      iptraf-ng
    ]) ++ [
      pciutils
      dnsutils

      # abcde # abcde -a cddb,read,encode,tag,move,playlist,clean,getalbumart -d /dev/cdrom -o mp3:-b320
      # easytag # requires configuration.nix 'programs.dconf.enable = true;'
      fatsort # fat32 file on disk sorter

      chafa # neovim telescope media_files image preview
      ffmpegthumbnailer # neovim telescope media_files video preview
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
      tree
      unzip
      xclip
      zip

      gcc # treesitter
      tree-sitter
      vale

      # https://nixos.wiki/wiki/Packaging/Binaries
      # file path/to/broken/file
      # ldd path/to/broken/file
      # Can patch interpreter for downloaded binary to the same interpeter used
      # by NixOS built package (which has correct interpreter set).
      # patchelf --set-interpreter $(patchelf --print-interpreter $(which cp)) path/to/broken/file
      patchelf
    ];

  # tree_sitter_bin = "<global_node_modules_path>/lib/node_modules/tree-sitter-cli/";
  # home.file.${tree_sitter_bin}.source = "${pkgs.tree-sitter}/bin/tree-sitter";

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

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.bash = {
    enable = true;

    initExtra = ''
      # Case-insensitive globbing (used in pathname expansion)
      shopt -s nocaseglob

      # Append to the Bash history file, rather than overwriting it
      shopt -s histappend

      # Autocorrect typos in path names when using `cd`
      shopt -s cdspell

      PATH=$PATH:~/.local/bin:~/go/bin/

      ${builtins.readFile ../dotfiles/functions.sh}

      ${builtins.readFile ../dotfiles/bash_prompt.sh}
    '';

    shellAliases = {
      # Enable aliases to be run with sudo
      sudo = "sudo ";

      # Always enable colored `grep` output
      grep = "grep --color=auto ";

      # Copy Paste between apps and in/out vm's
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";

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
      kdiff = "kitty +kitten diff $@";

      # IP addresses
      pubip = "dig +short myip.opendns.com @resolver1.opendns.com";
      localip =
        "sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'";
      ips =
        "sudo ip add | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'";

      # Patchelf Binaries that use incorrect interpreter
      pelf =
        "patchelf --set-interpreter $(patchelf --print-interpreter $(which cp)) $1";
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
        log \
        --color \
        --graph \
        --abbrev-commit \
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
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
      st = "status";
    };

    extraConfig = {
      fetch.prune = "true";
      init.defaultBranch = "main";
      pull.rebase = "true";
      push.default = "current";
      rebase.autosquash = "true";
    };
  };

  programs.gpg = {
    enable = true;
    settings = { pinentry-mode = "loopback"; };
  };

  services.blueman-applet.enable = {
    "x86_64-linux" = true;
    "aarch64-linux" = false;
    "aarch64-darwin" = false;
  }."${currentSystem}"; # bluetooth

  services.gpg-agent = {
    enable = isLinux;
    enableSshSupport = true;
    pinentryPackage =
      if isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;

    # cache the keys forever, rotate as require
    maxCacheTtl = 31536000;
    maxCacheTtlSsh = 31536000;
    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    defaultCacheTtlSsh = 31536000;

    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  programs.lazygit = { enable = true; };

  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    # package = pkgs.neovim-unwrapped; # unstable
    package = pkgs.neovim; # nightly via overlay
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
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

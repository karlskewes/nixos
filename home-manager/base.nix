{ config, pkgs, currentUser, currentEmailAddress, currentStateVersion, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";

  home.username = "${currentUser}";
  home.homeDirectory = "/home/${currentUser}";
  home.stateVersion = "${currentStateVersion}";

  # manage XDG directories
  xdg.enable = true;
  # recursively symlink LunarVim configuration
  # Note: lvim adds other files we don't need to persist into git
  xdg.configFile."lvim" = {
    source = ../dotfiles/lvim;
    recursive = true;
  };
  xdg.configFile."nvim" = {
    source = ../dotfiles/nvim;
    recursive = true;
  };
  xdg.configFile."vale.ini" = { source = ../dotfiles/vale.ini; };

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = with pkgs; [
    pciutils
    psmisc
    usbutils
    dnsutils

    # abcde # abcde -a cddb,read,encode,tag,move,playlist,clean,getalbumart -d /dev/cdrom -o mp3:-b320
    # easytag # requires configuration.nix 'programs.dconf.enable = true;'
    fatsort # fat32 file on disk sorter

    chafa # neovim telescope media_files image preview
    ffmpegthumbnailer # neovim telescope media_files video preview
    fd
    file
    gron # sed'able json
    htop
    iptraf-ng
    jq
    libqalculate # qalc - CLI calculator
    lsof
    nixfmt
    rename
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

    pinentry # gpg add ssh key
    # export GPG_TTY=$(tty)
    # export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    # gpg ssh-add -c -t 31536000 path/to/id_rsa
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
      # https://github.com/nix-community/home-manager/issues/1011
      # https://nix-community.github.io/home-manager/index.html#_why_are_the_session_variables_not_set
      # source our session variables otherwise not used in x sessions
      if [[ -f "/etc/profiles/per-user/${currentUser}/etc/profile.d/hm-session-vars.sh" ]]; then
        source "/etc/profiles/per-user/${currentUser}/etc/profile.d/hm-session-vars.sh"
      fi
      if [[ -f "/home/${currentUser}/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
        source "/home/${currentUser}/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi


      # Case-insensitive globbing (used in pathname expansion)
      shopt -s nocaseglob

      # Append to the Bash history file, rather than overwriting it
      shopt -s histappend

      # Autocorrect typos in path names when using `cd`
      shopt -s cdspell

      PATH=$PATH:~/.local/bin:~/go/bin/

      ${builtins.readFile ../dotfiles/functions.sh}
      KUBECONFIG=~/.kube/config

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

      # Remove if switch away from lunarvim to home-manager managed neovim
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      vimdiff = "nvim -d";

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
          repo = "bat"; # Bat uses sublime syntax for its themes
          rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
          # nix-shell -p nix-prefetch
          # nix-prefetch fetchFromGitHub --owner catppuccin --repo bat --rev ba4d16880d63e656acced2b7d4e034e4a93f74b1
          sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        };
        file = "Catppuccin-macchiato.tmTheme";
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
    userName = "Karl Skewes";
    userEmail = "${currentEmailAddress}";

    aliases = {
      co = "checkout";
      cob = "checkout -b";
      com = "checkout main";
      coms = "checkout master";
      c = "commit";
      ca = "commit --amend";
      caa = "commit --amend -a";
      cf = "commit --fixup";
      cm = "commit -m";
      d = "diff";
      fup = "fetch upstream";
      fuppr =
        "!f(){ git fetch upstream pull/\${1}/head:pr\${1}; git checkout pr\${1}; };f";
      fopr =
        "!f(){ git fetch origin pull/\${1}/head:pr\${1}; git checkout pr\${1}; };f";
      lg =
        "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      mupm = "merge upstream/main";
      mupms = "merge upstream/master";
      pr = "pull --rebase";
      rbi = "rebase --interactive";
      rbm = "rebase main";
      rbms = "rebase master";
      rbupm = "rebase upstream/main";
      rbupms = "rebase upstream/master";
      raup = "remote add upstream";
      s = "status";
      st = "status";
      prettylog =
        "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };

    extraConfig = {
      init.defaultBranch = "main";
      push.default = "current";
      rebase.autosquash = "true";
      url = {
        "ssh://git@github.com/karlskewes/" = {
          insteadOf = "https://github.com/karlskewes/";
        };
      };
    };
  };

  programs.gpg = {
    enable = true;
    settings = { pinentry-mode = "loopback"; };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "tty";

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
    # package = pkgs.neovim-nightly;
    package = pkgs.neovim-unwrapped;
    # vimAlias = true; # bash alias to LunarVim lvim instead
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

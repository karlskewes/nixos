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
  xdg.configFile."vale.ini" = { source = ../dotfiles/vale.ini; };

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = with pkgs; [
    pciutils
    psmisc
    usbutils
    dnsutils
    fatsort # fat32 file on disk sorter
    fd
    file
    fzf
    gron # sed'able json
    htop
    iptraf-ng
    jq
    libqalculate # qalc - CLI calculator
    lsof
    mage
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
    EDITOR = "lvim";
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

      ${builtins.readFile ../dotfiles/mage_completions.sh}

      ${builtins.readFile ../dotfiles/functions.sh}
      KUBECONFIG=~/.kube/config

      ${builtins.readFile ../dotfiles/bash_prompt.sh}
    '';

    shellAliases = {
      # Enable aliases to be run with suo
      sudo = "sudo ";

      # Always enable colored `grep` output
      grep = "grep --color=auto ";

      # Copy Paste between apps and in/out vm's
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";

      # Remove if switch away from doom-nvim to home-manager managed neovim
      v = "lvim";
      vi = "lvim";
      vim = "lvim";
      vimdiff = "lvim -d";

      # Easier navigation: .., ..., ...., ....., ~ and -
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

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
      theme = "Solarized (dark)";
      pager = "less --RAW-CONTROL-CHARS --ignore-case --hilite-unread --silent";
    };
  };

  programs.git = {
    enable = true;
    userName = "Karl Skewes";
    userEmail = "${currentEmailAddress}";

    aliases = {
      ca = "commit --amend";
      caa = "commit --amend -a";
      cm = "commit -m";
      co = "checkout";
      cob = "checkout -b";
      com = "checkout main";
      coms = "checkout master";
      fup = "fetch upstream";
      fuppr =
        "!f(){ git fetch upstream pull/\${1}/head:pr\${1}; git checkout pr\${1}; };f";
      mupm = "merge upstream/main";
      mupms = "merge upstream/master";
      rbm = "rebase main";
      rbms = "rebase master";
      rbupm = "rebase upstream/main";
      rbupms = "rebase upstream/master";
      raup = "remote add upstream";
      st = "status";
      prettylog =
        "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };

    extraConfig = {
      push.default = "current";
      rebase.autosquash = "true";
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
    package = pkgs.neovim-nightly;
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

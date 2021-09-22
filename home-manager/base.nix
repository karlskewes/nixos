{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "karl";
  home.homeDirectory = "/home/karl";

  # manage XDG directories
  xdg.enable = true;
  xdg.configFile."lvim/config.lua".text =
    builtins.readFile ../dotfiles/config.lua;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = with pkgs; [
    dnsutils
    fd
    file
    fzf
    htop
    jq
    libqalculate # qalc - CLI calculator
    lsof
    usbutils
    nixfmt
    pciutils
    psmisc
    rename
    ripgrep
    rpl
    tree
    unzip
    xclip
    zip

    # neovim
    luaformatter
    gcc # treesitter
    # TODO - consider using nightly overlay
    unstable.neovim
    nodejs
    nodePackages.npm
  ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
    PAGER = "less --ignore-case --hilite-unread --silent";
    MANPAGER = "less --ignore-case --hilite-unread --silent";
  };

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.bash = {
    enable = true;

    # source our session variables otherwise not used - unsure why
    initExtra = ''
      # source our session variables otherwise not used - unsure why
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

      # Case-insensitive globbing (used in pathname expansion)
      shopt -s nocaseglob

      # Append to the Bash history file, rather than overwriting it
      shopt -s histappend

      # Autocorrect typos in path names when using `cd`
      shopt -s cdspell

      PATH=$PATH:~/.local/bin

      ${builtins.readFile ../dotfiles/functions.sh}
      KUBECONFIG=~/.kube/config
      kubeconfigs

      ${builtins.readFile ../dotfiles/bash_prompt.sh}
    '';

    sessionVariables = {
      CDPATH = ".:~/src/github.com";
      # TODO - enable after setup lunarvim as part of flake
      # EDITOR = "lvim";
    };

    shellAliases = {

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

  programs.git = {
    enable = true;
    userName = "Karl Skewes";

    aliases = {
      ca = "commit --amend";
      caa = "commit --amend -a";
      cm = "commit -m";
      co = "checkout";
      cob = "checkout -b";
      com = "checkout main";
      coms = "checkout master";
      fup = "fetch upstream";
      rbm = "rebase main";
      rbms = "rebase master";
      rbupm = "rebase upstream/main";
      rbupms = "rebase upstream/master";
      st = "status";
      prettylog =
        "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };

    extraConfig = {
      # branch.autosetuprebase = "always";
      push.default = "current";
    };
  };

  programs.gpg = {
    enable = true;
    settings = { pinentry-mode = "loopback"; };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 30000;
    keyMode = "vi";
    shortcut = "z";
    terminal = "xterm-256color";

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      # Highlight current window with black background.
      setw -g window-status-current-style fg=white,bg=black,bright
      # renumber windows on close
      set-option -g renumber-windows on
      # Automatically set window title
      set-window-option -g automatic-rename on
      set-option -g set-titles on
      # Open new panes in PWD
      bind c new-window      -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
      # Automatically restore last tmux session
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '60' # minutes
    '';

    plugins = with pkgs; [
      { plugin = tmuxPlugins.resurrect; }
      { plugin = tmuxPlugins.continuum; }
      { plugin = tmuxPlugins.yank; }
    ];
  };

  # z - jump rust replacement
  programs.zoxide = { enable = true; };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;

    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}

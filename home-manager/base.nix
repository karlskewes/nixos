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
  # recursively symlink LunarVim configuration
  # Note: lvim adds other files we don't need to persist into git
  xdg.configFile."lvim" = {
    source = ../dotfiles/lvim;
    recursive = true;
  };

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
    jid # json repl
    libqalculate # qalc - CLI calculator
    lsof
    nixfmt
    rename
    ripgrep
    rpl
    tree
    unzip
    xclip
    zip

    # check how to pass 'unstable' through to programs.neovim.extraPackages
    # plus fix paths for neovim to find it
    gcc # treesitter
    unstable.tree-sitter
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

      PATH=$PATH:~/.local/bin:~/go/bin/

      ${builtins.readFile ../dotfiles/functions.sh}
      KUBECONFIG=~/.kube/config

      ${builtins.readFile ../dotfiles/bash_prompt.sh}
    '';

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

  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      luaformatter
      nerdfonts
      rnix-lsp
      # sumneko-lua-language-server # linux only - not working
    ];
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

{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "karl";
  home.homeDirectory = "/home/karl";

  # manage XDG directories
  xdg.enable = true;

  imports = [
    ./xwindows.nix
  ];
  
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
    zip
  ];
  
  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "vim";
    PAGER = "less --ignore-case --hilite-unread";
    MANPAGER = "less --ignore-case --hilite-unread";
  };

  # TODO # xdg.configFile."i3/config".text = builtins.readFile ./i3;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.alacritty = {
    enable = true;

    settings = {
      env.TERM = "xterm-256color";

      key_bindings = [
        { key = "V"; mods = "Command"; action = "Paste"; }
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Command"; action = "DecreaseFontSize"; }
      ];
    };
  };

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
    '';

    shellAliases = {
      pbcopy= "xclip -selection clipboard";
      pbpaste= "xclip -selection clipboard -o";

      # Easier navigation: .., ..., ...., ....., ~ and -
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";
     };
  };

  programs.git = {
    enable = true;
    userName = "Karl Skewes";
    userEmail = "karl.skewes@gmail.com";
    
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
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };
    
    extraConfig = {
      # branch.autosetuprebase = "always";
      push.default = "current"; 
    };
  };
  
  programs.gpg = {
    enable = true;
    settings = {
      pinentry-mode = "loopback";
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 30000;
    keyMode  = "vi";
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
    '';
    
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        # extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
      {
        plugin = tmuxPlugins.yank;
      }
    ];
  };

  services.gpg-agent = {
      enable = true;
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

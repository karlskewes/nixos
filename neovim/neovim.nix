{ # TODO - go down this path or stick with doom-nvim
  programs.neovim = {
    enable = true;
    package = nixos-unstable.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;

    extraPackages = with pkgs; [
      lua
      nodePackages.npm
    ];

    extraConfig = ''
      ${builtins.readFile ../neovim/init.vim}
      colorscheme delek

      lua << EOF
        ${builtins.readFile ../neovim/lspconfig.lua}

        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
          },
        }
      EOF
    '';

    # nix-env -f '<nixpkgs>' -qaP -A vimPlugins
    plugins = with pkgs.vimPlugins;
      let
        vim-shfmt = pkgs.vimUtils.buildVimPlugin {
          name = "vim-shfmt";
          src = pkgs.fetchFromGitHub {
            owner = "z0mbix";
            repo = "vim-shfmt";
            rev = "1f0e72322a8cb38805c276f7f3d10e21822b5376";
            sha256 = "14y911h2cax887wmkbw96s4kbh2acqlwpm3wy981msj9ksmksw6d";
          };
        };
        nixos-unstable = import <nixos-unstable> {};
      in [

      # fetched from GitHub
      vim-shfmt

      # packages
      # TODO from doom # galaxyline-nvim
      # TODO from doom # nvim-bufferline-lua
      telescope-nvim
      # REQUIRED? from doom # which-key-nvim

      # TODO figure out how? https://nixos.org/manual/nixpkgs/unstable/#vim
      # nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars)
      nvim-treesitter
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
      nvim-lspconfig
      # completion
      nixos-unstable.vimPlugins.nvim-cmp
      nixos-unstable.vimPlugins.cmp-buffer
      nixos-unstable.vimPlugins.cmp-nvim-lsp
      nixos-unstable.vimPlugins.cmp-nvim-lua
      nixos-unstable.vimPlugins.cmp_luasnip

      # languages
      bats
      vim-jinja
      vim-jsonnet
      vim-nix
      vim-terraform
    ];
  };

}

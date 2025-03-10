{ config, lib, pkgs, isDarwin, isLinux, ... }:

{
  xdg.configFile."nvim" = {
    source = ../../../dotfiles/nvim;
    recursive = true;
  };

  # run `vale sync` after fresh install to create `~/styles` directory.
  # https://github.com/errata-ai/vale/issues/211
  home.file.".vale.ini" = { source = ../../../dotfiles/vale.ini; };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    # package = pkgs.neovim-unwrapped; # unstable
    package = pkgs.neovim; # nightly via overlay
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # common dependency
      nvim-web-devicons

      # themes
      catppuccin-nvim

      # mini
      mini-align
      mini-diff
      mini-git
      mini-icons
      mini-pick
      mini-splitjoin
      mini-visits

      # lsp
      nvim-lspconfig
      fidget-nvim
      neodev-nvim
      blink-cmp

      # treesitter
      nvim-treesitter
      nvim-treesitter-context
      nvim-treesitter-textobjects
      # Option 2: Install specific grammar packages
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
        p.bash
        p.css
        p.csv
        p.diff
        p.dockerfile
        p.git_config
        p.git_rebase
        p.gitattributes
        p.gitcommit
        p.gitignore
        p.go
        p.gomod
        p.gosum
        p.gowork
        p.gotmpl
        p.html
        p.javascript
        p.json
        p.jsonnet
        p.lua
        p.make
        p.mermaid
        p.nix
        p.proto
        p.python
        p.rust
        p.sql
        p.templ
        p.terraform
        p.toml
        p.tsx
        p.typescript
        p.vimdoc
        p.vim
        p.vue
        p.yaml
        p.zig
      ]))

      # telescope
      telescope-nvim
      telescope-live-grep-args-nvim
      telescope-fzf-native-nvim
      # telescope-hierarchy-nvim
      plenary-nvim

      (telescope-hierarchy-nvim.overrideAttrs (_final: prev: {
        nvimSkipModule = [
          "telescope-hierarchy.ui"
          "telescope-hierarchy"
          "telescope-hierarchy.actions"
          "telescope-hierarchy.log"
          "telescope-hierarchy.defaults"
        ];
        # doCheck = false;
      }))

      # lang specific & debug
      namu-nvim
      nvim-nio
      nvim-dap
      nvim-dap-ui
      nvim-dap-go
      nvim-dap-python
      nvim-dap-virtual-text

      # other
      conform-nvim
      indent-blankline-nvim
      lualine-nvim
      oil-nvim
      trouble-nvim
      vim-sleuth
      which-key-nvim
    ];

    extraPackages = with pkgs;
      (lib.optionals isDarwin [ ]) ++ (lib.optionals isLinux [ ]) ++ [
        git

        chafa # neovim telescope media_files image preview
        ffmpegthumbnailer # neovim telescope media_files video preview

        fd
        ripgrep

        gcc # treesitter & telescope-fzf-native-nvim
        gnumake # telescope-fzf-native-nvim
        tree-sitter
        vale

        # lsp's
        bash-language-server
        eslint_d
        golangci-lint-langserver
        gopls
        jsonnet-language-server
        nil # nix
        nodePackages.prettier
        pyright
        rust-analyzer
        sqls
        sumneko-lua-language-server
        tailwindcss-language-server
        typescript
        typescript-language-server
        vscode-langservers-extracted # vscode-eslint-language-server
        vue-language-server
        yaml-language-server
      ];
  };

  # This file needs to be imported by `~/.config/nvim/init.lua`.
  xdg.configFile."nvim/lua/ts_ls.lua" = {
    # HACK: We need to provide nix store path to libraries which is only accessible
    # from .nix files, unless there's a way with lua using `$(which vue-language-server)` or
    # similar.
    # Solves for error: `Can't find typescript.js or tsserverlibrary.js in \"\"`
    text = # lua
      ''
        require('lspconfig').ts_ls.setup({
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                -- location = 'vue-language-server',
                location = '${pkgs.vue-language-server}/lib/node_modules/@vue/language-server',
                languages = { 'vue' },
              },
            },
          },
          filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
        })
      '';
  };
}

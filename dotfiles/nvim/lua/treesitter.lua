-- Highlight, edit, and navigate code
require('treesitter-context').setup({
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
  multiline_threshold = 2, -- Maximum number of lines to show for a single context
})

-- See `:help nvim-treesitter`

-- Get nix-provided parser directory
local nix_config = require('treesitter-nix-config')

-- Auto-enable treesitter highlighting for all filetypes
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    -- Skip special buffer types that shouldn't have treesitter
    local buftype = vim.bo[buf].buftype
    if buftype ~= '' then
      return
    end

    -- Get the treesitter language for this filetype
    local language = vim.treesitter.language.get_lang(filetype)
    if not language then
      return
    end

    -- Check if parser exists and load it
    if not pcall(vim.treesitter.language.add, language) then
      return
    end

    -- Try to enable syntax highlighting (may fail if parser not available)
    local ok = pcall(vim.treesitter.start, buf, language)
    if not ok then
      return
    end

    -- Enable treesitter based indentation
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Configure nvim-treesitter
require('nvim-treesitter.config').setup({
  -- Directory to install parsers and queries to (automatically prepended to runtimepath)
  install_dir = nix_config.parser_install_dir,
  auto_install = false, -- parsers installed via nix
  incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
    },
  })

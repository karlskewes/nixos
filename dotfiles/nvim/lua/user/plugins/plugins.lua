-- [[ Configure plugins ]]
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      vim.cmd.colorscheme('catppuccin')
    end,
    opts = {
      default_integrations = false,
      integrations = {
        cmp = true,
        dap = true,
        dap_ui = true,
        fidget = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
          },
        },
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },
  {
    'echasnovski/mini.diff',
    version = false,
    config = function()
      require('mini.diff').setup({
        view = {
          style = 'sign',
          signs = { add = '+', change = '~', delete = '-' },
        },
      })
    end,
  },
  {
    -- :Git commands.
    'echasnovski/mini-git',
    version = false,
    main = 'mini.git',
    config = function()
      require('mini.git').setup()

      vim.keymap.set('n', '<leader>ga', '<CMD>Git add %<CR>', { desc = '[G]it [a]dd buffer' })
      vim.keymap.set('n', '<leader>gA', '<CMD>Git add -A<CR>', { desc = '[G]it [A]dd all files' })
      vim.keymap.set('n', '<leader>gd', '<CMD>Git diff %<CR>', { desc = '[G]it [d]iff buffer' })
      vim.keymap.set('n', '<leader>gD', '<CMD>Git diff<CR>', { desc = '[G]it [D]iff all files' })
      -- show evaluation of line or selection, on commit hash to inspect full hash,
      -- on deleted line in git log to show file as was before commit.
      vim.keymap.set(
        'n',
        '<leader>gg',
        '<CMD>lua MiniGit.show_at_cursor()<CR>',
        { desc = '[G]it show at cursor' }
      )
      vim.keymap.set(
        'n',
        '<leader>gl',
        '<CMD>Git log --oneline<CR>',
        { desc = '[G]it [l]og --oneline' }
      )
      vim.keymap.set('n', '<leader>gr', '<CMD>Git reset %<CR>', { desc = '[G]it [r]eset buffer' })
      vim.keymap.set('n', '<leader>gs', '<CMD>Git status<CR>', { desc = '[G]it [s]tatus' })
    end,
  },
  {
    'echasnovski/mini.splitjoin',
    version = false,
    config = function()
      require('mini.splitjoin').setup({})
    end,
  },
  {
    'echasnovski/mini.visits',
    version = false,
    config = function()
      require('mini.visits').setup({
        track = { event = '' },
      })
      vim.keymap.set(
        'n',
        '<leader>va',
        '<CMD>lua MiniVisits.register_visit()<CR>',
        { desc = '[V]isits [a]dd' }
      )
      vim.keymap.set('n', '<leader>vd', function()
        vim.ui.select(MiniVisits.list_paths(), {}, function(choice)
          MiniVisits.remove_path(choice)
        end)
      end, { desc = '[V]isits [d]elete paths' })
      vim.keymap.set(
        'n',
        '<leader>vl',
        '<CMD>lua MiniVisits.list_paths()<CR>',
        { desc = '[V]isits [l]ist paths' }
      )
      vim.keymap.set(
        'n',
        '<leader>vn',
        '<CMD>lua MiniVisits.iterate_paths("forward", nil, { wrap = true })<CR>',
        { desc = '[V]isits [n]ext [<C-.>]' }
      )
      vim.keymap.set(
        'n',
        '<C-.>',
        '<CMD>lua MiniVisits.iterate_paths("forward", nil, { wrap = true })<CR>',
        { desc = '[V]isits [n]ext' }
      )
      vim.keymap.set(
        'n',
        '<leader>vp',
        '<CMD>lua MiniVisits.iterate_paths("backward", nil, { wrap = true })<CR>',
        { desc = '[V]isits [p]revious [<C-,>]' }
      )
      vim.keymap.set(
        'n',
        '<C-,>',
        '<CMD>lua MiniVisits.iterate_paths("backward", nil, { wrap = true })<CR>',
        { desc = '[V]isits [p]revious' }
      )
      vim.keymap.set(
        'n',
        '<leader>vr',
        '<CMD>lua MiniVisits.remove_path()<CR>',
        { desc = '[V]isits [r]emove path' }
      )
      vim.keymap.set(
        'n',
        '<leader>vs',
        '<CMD>lua MiniVisits.select_path()<CR>',
        { desc = '[V]isits [s]elect path' }
      )
    end,
  },
  {
    -- remember last place in file
    'ethanholz/nvim-lastplace',
    event = 'BufRead',
    config = function()
      require('nvim-lastplace').setup({
        lastplace_ignore_buftype = { 'quickfix', 'nofile', 'help' },
        lastplace_ignore_filetype = { 'gitcommit', 'gitrebase' },
        lastplace_open_folds = true,
      })
    end,
  },
  {
    -- List diagnostics, references, quickfix, etc to solve trouble your code is causing.
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    cmd = 'Trouble',
    keys = {
      { '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', desc = '[T]rouble Toggle' },
      {
        '<leader>tb',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = '[T]rouble [B]uffer Diagnostics',
      },
      {
        '<leader>ts',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = '[Trouble] [S]ymbols',
      },
      {
        '<leader>tr',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = '[T]rouble LSP [R]eferences',
      },
      { '<leader>tl', '<cmd>Trouble loclist toggle<cr>', desc = '[T]rouble [L]oclist' },
      { '<leader>tq', '<cmd>Trouble qflist toggle<cr>', desc = '[T]rouble [Q]uickfix' },
      {
        '<leader>tn',
        function()
          if require('trouble').is_open() then
            require('trouble').next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = '[T]rouble [n]ext',
      },
      {
        '<leader>tp',
        function()
          if require('trouble').is_open() then
            require('trouble').prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = '[T]rouble [p]revious',
      },
    },
  },
  {
    -- Display popup with possible key bindings.
    'folke/which-key.nvim',
    opts = {},
    config = function()
      require('which-key').setup({})

      -- document existing key chains
      require('which-key').register({
        ['<leader>b'] = { name = '[B]uffer', _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ebug', _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
        ['<leader>l'] = { name = '[L]sp', _ = 'which_key_ignore' },
        ['<leader>p'] = { name = '[P]lugins', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]rouble', _ = 'which_key_ignore' },
        ['<leader>v'] = { name = '[V]isits', _ = 'which_key_ignore' },
      })

      -- register which-key VISUAL mode
      -- required for visual <leader>gs (hunk stage) to work
      require('which-key').register({
        ['<leader>'] = { name = 'VISUAL <leader>' },
        ['<leader>g'] = { '[G]it Hunk' },
      }, { mode = 'v' })
    end,
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- See `:help lualine.txt`
    opts = function()
      local opts = {
        options = {
          theme = 'catppuccin',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      }

      local trouble = require('trouble')
      local symbols = trouble.statusline({
        mode = 'lsp_document_symbols',
        groups = {},
        title = false,
        filter = { range = true },
        format = '{kind_icon}{symbol.name:Normal}',
        -- The following line is needed to fix the background color
        -- Set it to the lualine section you want to use
        hl_group = 'lualine_c_normal',
      })
      table.insert(opts.sections.lualine_c, {
        symbols.get,
        cond = symbols.has,
      })

      return opts
    end,
  },
  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('go').setup()
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
  {
    -- File explorer, edit like a Neovim buffer
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup({
        keymaps = { ['<M-h>'] = 'actions.select_split' },
        view_options = { show_hidden = true },
      })

      -- Open parent directory in current window
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

      -- Open parent directory in floating window
      vim.keymap.set('n', '<space>-', require('oil').toggle_float)
    end,
  },
  {
    -- Detect tabstop and shiftwidth automatically.
    'tpope/vim-sleuth',
  },
}

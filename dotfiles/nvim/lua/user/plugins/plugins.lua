-- [[ Configure plugins ]]
return {
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
    -- Detect tabstop and shiftwidth automatically.
    'tpope/vim-sleuth',
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
        ['<leader>h'] = { name = '[H]arpoon', _ = 'which_key_ignore' }, -- though bindings not under <leader>h atm.
        ['<leader>l'] = { name = '[L]sp', _ = 'which_key_ignore' },
        ['<leader>p'] = { name = '[P]lugins', _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]rouble', _ = 'which_key_ignore' },
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
    -- List diagnostics, references, quickfix, etc to solve trouble your code is causing.
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('trouble').setup({})
      vim.keymap.set('n', '<leader>tt', function()
        require('trouble').toggle()
      end, { desc = '[T]rouble Toggle' })
      vim.keymap.set('n', '<leader>tn', function()
        require('trouble').next({ skip_groups = true, jump = true })
      end, { desc = '[T]rouble [n]ext' })
      vim.keymap.set('n', '<leader>tp', function()
        require('trouble').previous({ skip_groups = true, jump = true })
      end, { desc = '[T]rouble [p]revious' })
      vim.keymap.set('n', '<leader>tw', function()
        require('trouble').toggle('workspace_diagnostics')
      end, { desc = '[T]rouble [W]orkspace Diagnostics' })
      vim.keymap.set('n', '<leader>td', function()
        require('trouble').toggle('document_diagnostics')
      end, { desc = '[T]rouble [D]ocument Diagnostics' })
      vim.keymap.set('n', '<leader>tq', function()
        require('trouble').toggle('quickfix')
      end, { desc = '[T]rouble Quickfix' })
      vim.keymap.set('n', '<leader>tl', function()
        require('trouble').toggle('loclist')
      end, { desc = '[T]rouble Loclist' })
      vim.keymap.set('n', '<leader>tr', function()
        require('trouble').toggle('lsp_references')
      end, { desc = '[T]rouble LSP References' })
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
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
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
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({
        settings = {
          -- get_root_dir = function()
          --     local cwd = vim.loop.cwd()
          --     local root = vim.fn.system(
          --                      "git rev-parse --show-toplevel")
          --     if vim.v.shell_error == 0 and root ~= nil then
          --         return string.gsub(root, "\n", "")
          --     end
          --     return cwd
          -- end,
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      })

      vim.keymap.set('n', '<leader>ha', function()
        harpoon:list():add()
      end, { desc = '[H]arpoon [a]dd' })
      vim.keymap.set('n', '<leader>hl', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = '[H]arpoon [l]ist' })

      vim.keymap.set('n', '<leader>h1', function()
        harpoon:list():select(1)
      end, { desc = '[H]arpoon jump to [1]' })
      vim.keymap.set('n', '<leader>h2', function()
        harpoon:list():select(2)
      end, { desc = '[H]arpoon jump to [2]' })
      vim.keymap.set('n', '<leader>h3', function()
        harpoon:list():select(3)
      end, { desc = '[H]arpoon jump to [3]' })
      vim.keymap.set('n', '<leader>h4', function()
        harpoon:list():select(4)
      end, { desc = '[H]arpoon jump to [4]' })

      vim.keymap.set('n', '<C-,>', function()
        harpoon:list():prev()
      end, { desc = '[H]arpoon [p]revious' })
      vim.keymap.set('n', '<leader>hp', function()
        harpoon:list():prev()
      end, { desc = "[H]arpoon [p]revious '<C-,>'" })
      vim.keymap.set('n', '<C-.>', function()
        harpoon:list():next()
      end, { desc = '[H]arpoon [n]ext' })
      vim.keymap.set('n', '<leader>hn', function()
        harpoon:list():next()
      end, { desc = "[H]arpoon [n]ext '<C-.>'" })
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      vim.cmd.colorscheme('catppuccin')
    end,
    opts = {
      integrations = {
        alpha = true,
        cmp = true,
        dap = true,
        dap_ui = true,
        fidget = true,
        gitsigns = true,
        harpoon = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
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
    'ray-x/go.nvim',
    dependencies = { -- optional packages
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
}

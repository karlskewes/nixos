-- [[ Configure plugins ]]
return {
  {
    'neanias/everforest-nvim',
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('everforest').setup({
        -- background = 'hard',
        transparent_background_level = 0,
      })
      -- vim.cmd.colorscheme('everforest')
      -- vim.cmd('highlight Normal guibg=black')
    end,
  },
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
    -- useful for CSV's and tables, visual select -> ga, -> :set nowrap
    'echasnovski/mini.align',
    version = false,
    config = function()
      require('mini.align').setup()
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
    'echasnovski/mini.icons',
    version = false,
    config = function()
      require('mini.icons').setup()
    end,
  },
  {
    'echasnovski/mini.pick',
    dependencies = {
      'echasnovski/mini.icons',
    },
    version = false,
    config = function()
      require('mini.pick').setup()
    end,
  },
  {
    'echasnovski/mini.splitjoin',
    version = false,
    config = function()
      require('mini.splitjoin').setup()
    end,
  },
  {
    'echasnovski/mini.visits',
    dependencies = {
      'echasnovski/mini.pick',
    },
    version = false,
    config = function()
      -- find_git_root finds the git root directory starting with the provided file and
      -- falling back to the current working directory.
      ---@param current_file string
      ---@return string
      local function find_git_root(current_file)
        local current_dir
        local cwd = vim.fn.getcwd()
        if current_file == '' then
          current_dir = cwd
        else
          -- Extract the directory from the current file's path
          current_dir = vim.fn.fnamemodify(current_file, ':h')
        end

        -- Find the git root directory from the current file or dir path
        local cmd = { 'git', '-C', vim.fn.escape(current_dir, ' '), 'rev-parse', '--show-toplevel' }
        local result = vim.system(cmd, { text = true }):wait()
        if result.code ~= 0 then
          return current_dir
        end

        return vim.trim(result.stdout)
      end

      -- strip_git_root_path takes a git root directory and returns
      -- a function that strips the git root off the incoming path.
      ---@param git_root string
      ---@return function<string>: fn(path)
      local strip_git_root_path = function(git_root)
        local escaped_git_root = git_root:gsub('%-', '%%-') -- escape hyphen (non-greedy match char)
        return function(path)
          local trimmed_path, _ = path:gsub(escaped_git_root, '')
          return trimmed_path:gsub('^/', '') -- trim leading '/' if any.
        end
      end

      -- git_relative_source_items converts MiniVisits.list_paths() list/table with
      -- absolute paths into a MiniPick table with relative paths displayed (text)
      -- and underlying absolute paths (path) for navigation.
      ---@param items table
      ---@return table
      local function git_relative_source_items(items)
        local git_root = find_git_root('')
        local strip_git_root = strip_git_root_path(git_root)
        local new_items = {}

        for _, v in ipairs(items) do
          table.insert(new_items, { path = v, text = strip_git_root(v) })
        end

        return new_items
      end

      local alphabetical_sort = function(path_data_arr)
        local sorted_paths = vim.deepcopy(path_data_arr)
        table.sort(sorted_paths, function(a, b)
          return a.path < b.path
        end)
        return sorted_paths
      end

      require('mini.visits').setup({
        list = { sort = alphabetical_sort },
        track = { event = '' }, -- disable automatic path registration
      })

      vim.keymap.set(
        'n',
        '<leader>va',
        '<CMD>lua MiniVisits.register_visit()<CR>',
        { desc = '[V]isits [a]dd' }
      )
      vim.keymap.set(
        'n',
        '<leader>vd',
        function()
          local picker = require('mini.pick')
          local visits = require('mini.visits')

          -- remove_paths calls `mini.visits.remove_path(path)` for each item in the provided table.
          -- The table can either by a flat list of absolute paths which is the default
          -- `mini.visits.list_paths()` or it can be a `mini.pick` `source.items` table.
          ---@param items table
          local remove_paths = function(items)
            for _, v in ipairs(items) do
              local path = nil
              if type(v) == 'table' then
                -- per git_relative_source_items()
                -- { path = '/abs/path/to/file', text = 'file' }
                if v.path ~= nil then
                  path = v.path
                end
              else
                path = v
              end

              if path ~= nil then
                visits.remove_path(path)
              end
            end

            picker.set_picker_items(git_relative_source_items(visits.list_paths()))
            return true
          end

          picker.setup({
            source = {
              items = git_relative_source_items(visits.list_paths()),
              choose = function(item)
                return remove_paths({ item })
              end,
              choose_marked = remove_paths,
            },
          })

          picker.start()
        end, --
        { desc = '[V]isits [d]elete paths' }
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
        function()
          local picker = require('mini.pick')
          local visits = require('mini.visits')

          picker.setup({
            source = {
              items = git_relative_source_items(visits.list_paths()),
              choose = picker.default_choose,
              choose_marked = picker.default_choose_marked,
            },
          })

          picker.start()
        end, --
        -- <leader>vd keymap overrides choose functions, so vd -> vs will continue to delete
        -- marked. For now, just set picker back to defaults so selected will be edited.
        -- '<CMD>lua MiniPick.start({ source = { items = MiniVisits.list_paths()}})<CR>',
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
      { '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', { desc = '[T]rouble Toggle' } },
      {
        '<leader>tb',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        { desc = '[T]rouble [B]uffer Diagnostics' },
      },
      {
        '<leader>ts',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        { desc = '[Trouble] [S]ymbols' },
      },
      {
        '<leader>tr',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        { desc = '[T]rouble LSP [R]eferences' },
      },
      { '<leader>tl', '<cmd>Trouble loclist toggle<cr>', { desc = '[T]rouble [L]oclist' } },
      { '<leader>tq', '<cmd>Trouble qflist toggle<cr>', { desc = '[T]rouble [Q]uickfix' } },
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
        { desc = '[T]rouble [n]ext' },
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
        { desc = '[T]rouble [p]revious' },
      },
    },
  },
  {
    -- Display popup with possible key bindings.
    'folke/which-key.nvim',
    opts = {},
    config = function()
      require('which-key').setup({})

      local wk = require('which-key')
      wk.add({
        -- document existing key chains
        { '<leader>b', group = '[B]uffer' },
        { '<leader>b_', hidden = true },
        { '<leader>d', group = '[D]ebug' },
        { '<leader>d_', hidden = true },
        { '<leader>g', group = '[G]it' },
        { '<leader>g_', hidden = true },
        { '<leader>l', group = '[L]sp' },
        { '<leader>l_', hidden = true },
        { '<leader>p', group = '[P]lugins' },
        { '<leader>p_', hidden = true },
        { '<leader>s', group = '[S]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>t', group = '[T]rouble' },
        { '<leader>t_', hidden = true },
        { '<leader>v', group = '[V]isits' },
        { '<leader>v_', hidden = true },
      })
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
          lualine_x = { 'encoding' },
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
    build = ':lua require("go.install").update_all_sync()',
  },

  {
    -- Autoformat
    'stevearc/conform.nvim',
    config = function()
      local opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true, go = true }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = 'never'
          else
            lsp_format_opt = 'fallback'
          end
          return {
            timeout_ms = 500,
            lsp_fallback = lsp_format_opt,
          }
        end,
        formatters_by_ft = {
          go = { 'goimports', 'gofmt', 'gofumpt' }, -- TODO: drop gofmt
          hcl = { 'terraform_fmt' },
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
          jsonnet = { 'jsonnetfmt' },
          lua = { 'stylua' },
          markdown = { 'prettierd', 'prettier', stop_after_first = true },
          nix = { 'nixfmt' },
          proto = { 'buf' },
          python = { 'isort', 'black' },
          rust = { 'rustfmt' },
          sh = { 'shfmt' },
          sql = { 'sql_formatter' },
          templ = { 'templ' },
          terraform = { 'terraform_fmt' },
          yaml = { 'prettierd', 'prettier', stop_after_first = true },
          zig = { 'zigfmt' },
        },
      }

      require('conform').setup(opts)

      vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end, { desc = '[F]ormat buffer' })
    end,
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

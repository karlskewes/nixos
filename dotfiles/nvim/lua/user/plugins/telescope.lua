return {
  -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim',
    {
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available.
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable('make') == 1
      end,
    },
  },
  config = function()
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup({
      defaults = {
        layout_strategy = 'vertical',
        layout_config = {
          height = 0.95,
          preview_height = 0.70,
        },
      },
      extensions = {
        live_grep_args = {
          auto_quoting = false, -- enable/disable auto-quoting
        },
      },
    })

    -- Enable telescope extensions, if installed
    pcall(require('telescope').load_extension('fzf'))
    pcall(require('telescope').load_extension('live_grep_args'))

    -- Telescope live_grep in git root
    -- find_git_root finds the git root directory starting with the provided file and
    -- falling back to the current working directory.
    ---@return string
    local function find_git_root()
      -- Use the current buffer's path as the starting point for the git search
      local current_file = vim.api.nvim_buf_get_name(0)
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
        print('Not a git repository. Searching on current working directory:', current_dir)
        return current_dir
      end

      return vim.trim(result.stdout)
    end

    -- strip_git_root_path takes a git root directory and returns
    -- a function conforming to path_display that strips the git root
    -- off the incoming path. This is useful for live_grep.
    ---@param git_root string
    ---@return function<table, string>: path_display(opts, path)
    local strip_git_root_path = function(git_root)
      local escaped_git_root = git_root:gsub('%-', '%%-') -- escape hyphen (non-greedy match char)
      return function(_, path)
        local trimmed_path, _ = path:gsub(escaped_git_root, '')
        return trimmed_path:gsub('^/', '') -- trim leading '/' if any.
      end
    end

    -- live_grep_args_git_root calls the `live_grep_args` extension anchored in the
    -- current git root directory.
    ---@param text string
    local function live_grep_args_git_root(text)
      local git_root = find_git_root()
      local pd = strip_git_root_path(git_root)
      local opts = {
        search_dirs = { git_root },
        path_display = pd,
      }

      if text ~= '' then
        opts['default_text'] = text
      end

      require('telescope').extensions.live_grep_args.live_grep_args(opts)
    end

    -- See `:help telescope.builtin`
    vim.keymap.set(
      'n',
      '<leader>?',
      require('telescope.builtin').oldfiles,
      { desc = '[?] Find recently opened files' }
    )
    vim.keymap.set(
      'n',
      '<leader><space>',
      require('telescope.builtin').buffers,
      { desc = '[ ] Find existing buffers' }
    )
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      require('telescope.builtin').current_buffer_fuzzy_find(
        require('telescope.themes').get_dropdown({
          winblend = 10,
          previewer = false,
        })
      )
    end, { desc = '[/] Fuzzily search in current buffer' })

    local function telescope_live_grep_open_files()
      require('telescope.builtin').live_grep({
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      })
    end

    vim.keymap.set(
      'n',
      '<leader>s/',
      telescope_live_grep_open_files,
      { desc = '[S]earch [/] in Open Files' }
    )
    vim.keymap.set(
      'n',
      '<leader>sa',
      live_grep_args_git_root,
      { desc = '[S]earch git with [A]rgs ' }
    )
    vim.keymap.set(
      'n',
      '<leader>sd',
      require('telescope.builtin').diagnostics,
      { desc = '[S]earch [D]iagnostics' }
    )
    vim.keymap.set(
      'n',
      '<leader>sF',
      require('telescope.builtin').find_files,
      { desc = '[S]earch [F]iles' }
    )
    vim.keymap.set(
      'n',
      '<leader>sf',
      require('telescope.builtin').git_files,
      { desc = '[S]earch git [f]iles' }
    )
    vim.keymap.set(
      'n',
      '<leader>sh',
      require('telescope.builtin').help_tags,
      { desc = '[S]earch [H]elp' }
    )
    vim.keymap.set(
      'n',
      '<leader>sk',
      require('telescope.builtin').keymaps,
      { desc = '[S]earch [K]eymaps' }
    )
    vim.keymap.set(
      'n',
      '<leader>sG',
      require('telescope.builtin').live_grep,
      { desc = '[S]earch by [G]rep' }
    )
    vim.keymap.set(
      'n',
      '<leader>sg',
      live_grep_args_git_root,
      { desc = '[S]earch by [g]rep on Git Root' }
    )
    vim.keymap.set('n', '<leader>sn', function()
      local working_dir = vim.fn.stdpath('config')
      require('telescope.builtin').find_files({ cwd = working_dir })
    end, { desc = '[S]earch [N]eovim files' })
    vim.keymap.set(
      'n',
      '<leader>sr',
      require('telescope.builtin').resume,
      { desc = '[S]earch [R]esume' }
    )
    vim.keymap.set(
      'n',
      '<leader>ss',
      require('telescope.builtin').builtin,
      { desc = '[S]earch [S]elect Telescope' }
    )
    vim.keymap.set(
      'n',
      '<leader>sv',
      require('telescope.builtin').git_commits,
      { desc = '[S]earch [v]cs' }
    )
    vim.keymap.set(
      'n',
      '<leader>sv<CR>',
      require('telescope.builtin').git_commits,
      { desc = '[S]earch [v]cs commits' }
    )
    vim.keymap.set(
      'n',
      '<leader>svc',
      require('telescope.builtin').git_commits,
      { desc = '[S]earch [v]cs [c]ommits' }
    )
    vim.keymap.set(
      'n',
      '<leader>svb',
      require('telescope.builtin').git_bcommits,
      { desc = '[S]earch [v]cs [b]uffer' }
    )
    vim.keymap.set(
      'n',
      '<leader>svs',
      require('telescope.builtin').git_status,
      { desc = '[S]earch [v]cs status' }
    )
    vim.keymap.set(
      'n',
      '<leader>svS',
      require('telescope.builtin').git_stash,
      { desc = '[S]earch [v]cs [S]tash' }
    )
    vim.keymap.set('n', '<leader>sw', function()
      local word = vim.fn.expand('<cword>')
      live_grep_args_git_root(word)
    end, { desc = '[S]earch current [w]ord' })
    vim.keymap.set('n', '<leader>sW', function()
      local word = vim.fn.expand('<cWORD>')
      live_grep_args_git_root(word)
    end, { desc = '[S]earch current [W]ORD' })
  end,
}

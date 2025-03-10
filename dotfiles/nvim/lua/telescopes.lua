-- Fuzzy Finder (files, lsp, etc).
-- File called telescopes.lua to avoid init.lua performing setup without configuration.
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup({
  defaults = {
    layout_strategy = 'vertical', -- better for vertical split screen with terminal
    layout_config = {
      height = 0.95,
    },
    preview_height = 0.70,
  },
  extensions = {
    hierarchy = {
      layout_strategy = 'vertical', -- better for vertical split screen with terminal
      multi_depth = 2, -- Default = 5 - How many layers deep should a multi-expand(E) go?
    },
    live_grep_args = {
      auto_quoting = false, -- enable/disable auto-quoting
    },
  },
})

-- Enable telescope extensions, if installed
pcall(require('telescope').load_extension('fzf'))
pcall(require('telescope').load_extension('live_grep_args'))
pcall(require('telescope').load_extension('hierarchy'))

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
    local git_relative_path, _ = path:gsub(escaped_git_root, '')
    local trimmed_path, _ = git_relative_path:gsub('^/', '') -- trim leading '/' if any.
    return trimmed_path
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

-- git_modified displays a picker of git modified but not staged or committed files.
local function git_modified()
  local conf = require('telescope.config').values
  local finders = require 'telescope.finders'
  local make_entry = require 'telescope.make_entry'
  local pickers = require 'telescope.pickers'
  local previewers = require 'telescope.previewers'
  local utils = require 'telescope.utils'
  local git_command = utils.__git_command

  local opts = {}

  -- TODO: use a different cwd? and entry_maker and display paths from git root
  opts.entry_maker = vim.F.if_nil(opts.entry_maker, make_entry.gen_from_file(opts))
  opts.git_command = vim.F.if_nil(
    opts.git_command,
    git_command({
      'ls-files', -- main git command
      '--modified', -- show only modified files that aren't staged
      '--deduplicate', -- remove duplicates
      find_git_root(), -- pass git root so returned file paths are displayed relative to cwd.
    }, opts)
  )

  pickers
    .new(opts, {
      prompt_title = 'Git Modified',
      __locations_input = true,
      finder = finders.new_oneshot_job(
        utils.flatten {
          opts.git_command,
        },
        opts
      ),
      previewer = previewers.git_file_diff.new(opts),
      -- previewer = conf.file_previewer(opts),
      sorter = conf.file_sorter(opts),
    })
    :find()
end

-- See `:help telescope.builtin`
local tsb = require('telescope.builtin')
vim.keymap.set('n', '<leader>?', tsb.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', tsb.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  tsb.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  tsb.live_grep({
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
vim.keymap.set('n', '<leader>sd', tsb.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sF', tsb.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sf', tsb.git_files, { desc = '[S]earch git [f]iles' })
vim.keymap.set('n', '<leader>sh', tsb.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', tsb.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sG', tsb.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set(
  'n',
  '<leader>sg',
  live_grep_args_git_root,
  { desc = '[S]earch by [g]rep on Git Root' }
)
vim.keymap.set('n', '<leader>sn', function()
  local working_dir = vim.fn.stdpath('config')
  tsb.find_files({ cwd = working_dir })
end, { desc = '[S]earch [N]eovim files' })
vim.keymap.set('n', '<leader>sr', tsb.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>ss', tsb.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sv', tsb.git_commits, { desc = '[S]earch [v]cs' })
vim.keymap.set('n', '<leader>sv<CR>', tsb.git_commits, { desc = '[S]earch [v]cs commits' })
vim.keymap.set('n', '<leader>svb', tsb.git_bcommits, { desc = '[S]earch [v]cs [b]uffer' })
vim.keymap.set('n', '<leader>svc', tsb.git_commits, { desc = '[S]earch [v]cs [c]ommits' })
vim.keymap.set('n', '<leader>svm', git_modified, { desc = '[S]earch [v]cs [m]odified' })
vim.keymap.set('n', '<leader>svs', tsb.git_status, { desc = '[S]earch [v]cs status' })
vim.keymap.set('n', '<leader>svS', tsb.git_stash, { desc = '[S]earch [v]cs [S]tash' })
-- telescope-hierarchy.nvim
vim.keymap.set(
  'n',
  '<leader>si',
  '<cmd>Telescope hierarchy incoming_calls<cr>',
  { desc = 'LSP: [S]earch [I]ncoming Calls' }
)
vim.keymap.set(
  'n',
  '<leader>so',
  '<cmd>Telescope hierarchy outgoing_calls<cr>',
  { desc = 'LSP: [S]earch [O]utgoing Calls' }
)
-- live_grep
vim.keymap.set('n', '<leader>sw', function()
  local word = vim.fn.expand('<cword>')
  live_grep_args_git_root(word)
end, { desc = '[S]earch current [w]ord' })

vim.keymap.set('n', '<leader>sW', function()
  local word = vim.fn.expand('<cWORD>')
  live_grep_args_git_root(word)
end, { desc = '[S]earch current [W]ORD' })

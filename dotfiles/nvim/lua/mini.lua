-- useful for CSV's and tables, visual select -> ga, -> :set nowrap
require('mini.align').setup()

require('mini.diff').setup({
  view = {
    style = 'sign',
    signs = { add = '+', change = '~', delete = '-' },
  },
})

-- :Git commands.
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
vim.keymap.set('n', '<leader>gl', '<CMD>Git log --oneline<CR>', { desc = '[G]it [l]og --oneline' })
vim.keymap.set('n', '<leader>gr', '<CMD>Git reset %<CR>', { desc = '[G]it [r]eset buffer' })
vim.keymap.set('n', '<leader>gs', '<CMD>Git status<CR>', { desc = '[G]it [s]tatus' })

require('mini.icons').setup()
require('mini.pick').setup()
require('mini.extra').setup() -- extra pickers for mini.pick
require('mini.splitjoin').setup()

-- :MiniVisits
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

-- git_root utilises fzf-lua to return the git root, falling back to the
-- current working directory.
---@return string
-- local function git_root_or_cwd()
--   local path = fzf.path.git_root(vim.loop.cwd(), true)
--   if path == nil then
--     return vim.fn.getcwd()
--   end
--
--   return path
-- end

-- See `:help fzf-lua-commands`
vim.keymap.set(
  'n',
  '<leader>?',
  '<Cmd>Pick oldfiles<CR>',
  { desc = '[?] Find recently opened files' }
)
vim.keymap.set(
  'n',
  '<leader>sl',
  '<Cmd>Pick buf_lines scope="current"<CR>',
  { desc = '[S]earch buffer lines (current)' }
)
vim.keymap.set(
  'n',
  '<leader>sL',
  '<Cmd>Pick buf_lines scope="all"<CR>',
  { desc = '[S]earch buffer lines (all)' }
)
vim.keymap.set('n', '<leader><space>', '<Cmd>Pick buffers<CR>', { desc = '[ ] Pick Buffers' })
vim.keymap.set('n', '<leader>sb', '<Cmd>Pick buffers<CR>', { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>sd', '<Cmd>Pick diagnostic<CR>', { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sF', '<Cmd>Pick files<CR>', { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sf', '<Cmd>Pick git_files<CR>', { desc = '[S]earch git [f]iles' })
vim.keymap.set('n', '<leader>sh', '<Cmd>Pick help<CR>', { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', '<Cmd>Pick keymaps<CR>', { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sG', '<Cmd>Pick grep_live<CR>', { desc = '[S]earch by [G]rep' })
vim.keymap.set(
  'n',
  '<leader>sg',
  '<Cmd>Pick grep_live<CR>', -- todo git files?
  { desc = '[S]earch by [G]rep' }
)
vim.keymap.set('n', '<leader>sn', function()
  local working_dir = vim.fn.stdpath('config')
  local picker = require('mini.pick')
  picker.setup({
    source = { cwd = working_dir },
  })

  picker.start()
end, { desc = '[S]earch [N]eovim files' }) -- TODO: not working, grab new picker var?
vim.keymap.set('n', '<leader>sr', '<Cmd>Pick resume<CR>', { desc = '[S]earch [R]esume' })
-- vim.keymap.set('n', '<leader>ss', picker.builtin, { desc = '[S]earch [S]elect' }) -- TODO: not available?
vim.keymap.set('n', '<leader>sv', '<Cmd>Pick git_commits<CR>', { desc = '[S]earch [v]cs' })
vim.keymap.set(
  'n',
  '<leader>sv<CR>',
  '<Cmd>Pick git_commits<CR>',
  { desc = '[S]earch [v]cs commits' }
)
-- vim.keymap.set('n', '<leader>svb', picker.git_bcommits, { desc = '[S]earch [v]cs [b]uffer' })
vim.keymap.set(
  'n',
  '<leader>svc',
  '<Cmd>Pick git_commits<CR>',
  { desc = '[S]earch [v]cs [c]ommits' }
)
vim.keymap.set('n', '<leader>svh', '<Cmd>Pick git_hunks<CR>', { desc = '[S]earch [v]cs [h]unks' })
-- Not implemented: https://github.com/nvim-mini/mini.nvim/issues/550#issuecomment-1805477794
-- vim.keymap.set('n', '<leader>svs', picker.git_status, { desc = '[S]earch [v]cs status' })
-- vim.keymap.set('n', '<leader>svS', picker.git_stash, { desc = '[S]earch [v]cs [S]tash' })
vim.keymap.set(
  'n',
  '<leader>sw',
  '<Cmd>Pick grep pattern="<cword>"<CR>',
  { desc = '[S]earch current [w]ord' }
)
vim.keymap.set(
  'n',
  '<leader>sW',
  '<Cmd>Pick grep pattern="<cWORD>"<CR>',
  { desc = '[S]earch current [W]ORD' }
)

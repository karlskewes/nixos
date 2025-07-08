-- Fuzzy Finder (files, lsp, etc).

local fzf = require('fzf-lua')

fzf.setup({
  previewers = {
    builtin = {
      extensions = {
        -- by default the filename is added as last argument
        -- if required, use `{file}` for argument positioning
        ['png'] = { 'chafa' },
        ['svg'] = { 'chafa' },
        ['jpg'] = { 'chafa' },
      },
    },
  },
})

-- git_root utilises fzf-lua to return the git root, falling back to the
-- current working directory.
---@return string
local function git_root_or_cwd()
  local path = fzf.path.git_root(vim.loop.cwd(), true)
  if path == nil then
    return vim.fn.getcwd()
  end

  return path
end

-- See `:help fzf-lua-commands`
vim.keymap.set('n', '<leader>?', fzf.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>s/', fzf.lgrep_curbuf, { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader><space>', fzf.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sb', fzf.buffers, { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sF', fzf.files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sf', fzf.git_files, { desc = '[S]earch git [f]iles' })
vim.keymap.set('n', '<leader>sh', fzf.helptags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sG', fzf.live_grep_glob, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sg', function()
  fzf.live_grep_glob({ cwd = git_root_or_cwd() })
end, { desc = '[S]earch by [g]rep on Git Root' })
vim.keymap.set('n', '<leader>sn', function()
  local working_dir = vim.fn.stdpath('config')
  fzf.files({ cwd = working_dir })
end, { desc = '[S]earch [N]eovim files' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect' })
vim.keymap.set('n', '<leader>sv', fzf.git_commits, { desc = '[S]earch [v]cs' })
vim.keymap.set('n', '<leader>sv<CR>', fzf.git_commits, { desc = '[S]earch [v]cs commits' })
vim.keymap.set('n', '<leader>svb', fzf.git_bcommits, { desc = '[S]earch [v]cs [b]uffer' })
vim.keymap.set('n', '<leader>svc', fzf.git_commits, { desc = '[S]earch [v]cs [c]ommits' })
vim.keymap.set('n', '<leader>svh', fzf.git_hunks, { desc = '[S]earch [v]cs [h]unks' })
vim.keymap.set('n', '<leader>svs', fzf.git_status, { desc = '[S]earch [v]cs status' })
vim.keymap.set('n', '<leader>svS', fzf.git_stash, { desc = '[S]earch [v]cs [S]tash' })
vim.keymap.set('n', '<leader>sw', function()
  fzf.grep_cword({ cwd = git_root_or_cwd() })
end, { desc = '[S]earch current [w]ord' })
vim.keymap.set('n', '<leader>sW', function()
  fzf.grep_cWORD({ cwd = git_root_or_cwd() })
end, { desc = '[S]earch current [W]ORD' })

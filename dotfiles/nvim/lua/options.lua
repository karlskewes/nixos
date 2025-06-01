-- [[ Setting options ]]
-- See `:help vim.o`
vim.o.hidden = true -- required to keep multiple buffers and open multiple buffers
vim.o.hlsearch = true -- Set highlight on search, easier to spot.
-- vim.o.statuscolumn = '%s %l' -- sign, line
vim.wo.number = true -- Show line numbers
vim.wo.relativenumber = false -- Show relative line numbers
vim.wo.signcolumn = 'yes' -- Keep signcolumn on by default
vim.o.clipboard = '' -- don't default to system clipboard (<C-y|p>)
vim.o.breakindent = true
vim.o.expandtab = true
vim.o.mouse = 'a' -- Enable mouse mode
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search
vim.o.smartcase = true
-- Decrease update time
vim.o.updatetime = 50
vim.o.timeoutlen = 200
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.o.foldlevel = 99
vim.o.foldmethod = 'indent' -- folding, leaves declaration line open
vim.o.formatoptions = 'qrn1' -- handle formatting nicely
vim.o.scrolloff = 8
vim.o.colorcolumn = '100'
vim.o.termguicolors = true
-- vim.o.textwidth = 99 -- wrap at this character number on whitespace, set per filetype.
vim.o.undofile = true
vim.o.winborder = 'single' -- floating window border style, padding not available.
vim.o.wrap = true -- don't display lines as one long line
vim.o.spelllang = 'en_us'
vim.o.spell = true

-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>n', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Buffer keymaps
vim.keymap.set('n', '<leader>c', '<cmd>:bd|bo<CR>', { desc = 'Close Buffer' })
vim.keymap.set('n', '<leader>w', '<cmd>w!<CR>', { desc = 'Write/Save' })
vim.keymap.set('n', '<leader>W', '<cmd>noautocmd w<CR>', { desc = 'Write/Save (no actions)' })
vim.keymap.set('n', '<leader>q', '<cmd>confirm q<CR>', { desc = 'Quit' })
vim.keymap.set('n', 'zz', 'zA', { desc = 'Toggle folds' })

-- Resize buffers with arrows
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', {})
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', {})
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', {})
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', {})

-- Move current line / block with Alt-j/k ala vscode.
vim.keymap.set('n', '<A-j>', ': .+1<CR>==gi', { desc = 'move line/block down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==gi', { desc = 'move line/block up' })
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { desc = 'move line/block down' })
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { desc = 'move line/block up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv-gv", { desc = 'move line/block down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv-gv", { desc = 'move line/block up' })

-- When searching, keep search term with cursor in the middle of buffer.
vim.keymap.set('n', 'n', 'nzzzv', {})
vim.keymap.set('n', 'N', 'Nzzzv', {})

-- Quickfix list navigation
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz', {}) -- [q but without zz centering
vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz', {}) -- ]q but without zz centering
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", {}) -- ]l
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", {}) -- [l
vim.cmd([[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]])
vim.keymap.set('n', '<C-q>', ':call QuickFixToggle()<CR>', {})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Set gohtml files to HTML syntax highlighting
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { '*.gohtml' },
  command = 'set filetype=gohtmltmpl',
})

-- Trim all trailing whitespace
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*' },
  -- @ separater, double back slash for lua escape
  command = ':%s@\\s\\+$@@e',
})

-- Jump to last place in files when opened
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  desc = 'jump to last visited position in file',
  pattern = { '*' },
  command = 'silent! normal! g`"zz',
})

-- [[ Setting options ]]
-- See `:help vim.o`
vim.o.hidden = true -- required to keep multiple buffers and open multiple buffers
vim.o.hlsearch = false -- Set highlight on search
vim.wo.number = true -- Make line numbers default
vim.wo.signcolumn = 'yes' -- Keep signcolumn on by default
vim.o.mouse = 'a' -- Enable mouse mode
vim.o.clipboard = "" -- don't default to system clipboard (<C-y|p>)
vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true -- Save undo history
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search
vim.o.smartcase = true
-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.o.termguicolors = true
vim.o.colorcolumn = "100"
vim.o.foldmethod = "indent" -- folding, leaves declaration line open
vim.o.formatoptions = "qrn1" -- handle formatting nicely
vim.o.textwidth = 99 -- wrap at this character number on whitespace
vim.o.wrap = true -- don't display lines as one long line

vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`
vim.keymap.set({'n', 'v'}, '<Space>', '<Nop>', {silent = true})

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'",
               {expr = true, silent = true})
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'",
               {expr = true, silent = true})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
               {desc = 'Go to previous diagnostic message'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
               {desc = 'Go to next diagnostic message'})
vim.keymap.set('n', '<leader>m', vim.diagnostic.open_float,
               {desc = 'Open floating diagnostic message'})
vim.keymap.set('n', '<leader>n', vim.diagnostic.setloclist,
               {desc = 'Open diagnostics list'})

-- Buffer keymaps
vim.keymap.set("n", "<leader>c", "<cmd>:bd|bo<CR>", {desc = "Close Buffer"})
vim.keymap.set("n", "<leader>w", "<cmd>w!<CR>", {desc = "Write/Save"})
vim.keymap.set("n", "<leader>q", "<cmd>confirm q<CR>", {desc = "Quit"})
vim.keymap.set("n", "zz", 'zA', {desc = "Toggle folds"})

-- Resize buffers with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", {})
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", {})
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", {})
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", {})

-- Move current line / block with Alt-j/k ala vscode.
vim.keymap.set("n", "<A-j>", ": .+1<CR>==gi", {desc = "move line/block down"})
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==gi", {desc = "move line/block up"})
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi",
               {desc = "move line/block down"})
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi",
               {desc = "move line/block up"})
vim.keymap
    .set("v", "<A-j>", ":m '>+1<CR>gv-gv", {desc = "move line/block down"})
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv-gv", {desc = "move line/block up"})

-- When searching, keep search term with cursor in the middle of buffer.
vim.keymap.set("n", "n", "nzzzv", {})
vim.keymap.set("n", "N", "Nzzzv", {})

-- Quickfix list navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", {})
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", {})
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", {})
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", {})
vim.keymap.set("n", "<C-q>", ":call QuickFixToggle()<CR>", {})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight',
                                                    {clear = true})
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank() end,
    group = highlight_group,
    pattern = '*'
})

-- Set gohtml files to HTML syntax highlighting
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.gohtml"},
    command = "set filetype=gohtmltmpl"
})

-- Trim all trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {"*"},
    -- @ separater, double back slash for lua escape
    command = ":%s@\\s\\+$@@e"
})


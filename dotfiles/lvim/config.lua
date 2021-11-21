--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "onedarker"
vim.opt.diffopt = "internal,filler,closeoff,iwhite" -- disable vimdiff whitespace showing - can't += here
vim.opt.undofile = false -- disable persistent undo, habitual git + ctrl-u to no-changes
vim.opt.relativenumber = false -- set relative numbered lines
vim.opt.clipboard = "" -- don't default to system clipboard (<C-y|p>)
vim.opt.colorcolumn = "80"
vim.opt.formatoptions = "qrn1" -- handle formatting nicely
vim.opt.textwidth = 79 -- wrap at this character number on whitespace
vim.opt.wrap = true -- don't display lines as one long line
lvim.keys.insert_mode["<C-p>"] = '<ESC>p' -- paste from unamed register - <C-V> for pasting from system clipboard
lvim.keys.normal_mode["<C-y>"] = '"+y' -- 10<C-y><CR> - copy 10 lines to system clipboard
lvim.keys.normal_mode["<C-p>"] = '"+p' -- paste from system clipboard
lvim.keys.visual_mode["<C-y>"] = '"+y' -- copy block to system clipboard
lvim.keys.visual_mode["<C-p>"] = '"+p' -- paste block from system clipboard

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
-- lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = ""
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- lvim.builtin.telescope.on_config_done = function()
--   local actions = require "telescope.actions"
--   -- for input mode
--   lvim.builtin.telescope.defaults.mappings.i["<C-j>"] = actions.move_selection_next
--   lvim.builtin.telescope.defaults.mappings.i["<C-k>"] = actions.move_selection_previous
--   lvim.builtin.telescope.defaults.mappings.i["<C-n>"] = actions.cycle_history_next
--   lvim.builtin.telescope.defaults.mappings.i["<C-p>"] = actions.cycle_history_prev
--   -- for normal mode
--   lvim.builtin.telescope.defaults.mappings.n["<C-j>"] = actions.move_selection_next
--   lvim.builtin.telescope.defaults.mappings.n["<C-k>"] = actions.move_selection_previous
-- end

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
-- }

-- User Config for predefined plugins




-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.lualine.active = true
lvim.builtin.lualine.style = "default"
lvim.builtin.lualine.options.theme = "solarized_dark"
-- broken
-- lvim.builtin.lualine.options.theme = "auto"
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings
-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end
-- you can overwrite the null_ls setup table (useful for setting the root_dir function)
-- lvim.lsp.null_ls.setup = {
--   root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
-- }
-- or if you need something more advanced
-- lvim.lsp.null_ls.setup.root_dir = function(fname)
--   if vim.bo.filetype == "javascript" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "node_modules")(fname)
--       or require("lspconfig/util").path.dirname(fname)
--   elseif vim.bo.filetype == "php" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "composer.json")(fname) or vim.fn.getcwd()
--   else
--     return require("lspconfig/util").root_pattern("Makefile", ".git")(fname) or require("lspconfig/util").path.dirname(fname)
--   end
-- end

-- ---@usage setup a server -- see: https://www.lunarvim.org/languages/#overriding-the-default-configuration
-- TODO: Fix lua
-- require("lvim.lsp.manager").setup("sumneko_lua")

-- set a formatter if you want to override the default lsp one (if it exists)
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   go = { "gofumpt" }
-- }

-- Additional Plugins
lvim.plugins = {
	{ 'aliou/bats.vim' },
	{ 'google/vim-jsonnet' },
	{
    'hashivim/vim-terraform',
    config = function()
      vim.cmd("let g:terraform_fmt_on_save=1")
      -- "Allow vim-terraform to automatically fold (hide until unfolded) sections of terraform code.
      -- vim.cmd("let g:terraform_fold_sections=0")
    end,
  },
	{
    'z0mbix/vim-shfmt',
    config = function()
      vim.cmd("let g:shfmt_fmt_on_save = 1")
    end,
  },
  {
  "ray-x/lsp_signature.nvim",
  event = "BufRead",
  config = function()
    require "lsp_signature".setup()
  end
  },
  {
		"ethanholz/nvim-lastplace",
		event = "BufRead",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
				lastplace_ignore_filetype = {
					"gitcommit", "gitrebase", "svn", "hgcommit",
				},
				lastplace_open_folds = true,
			})
		end,
	},
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
lvim.autocommands.custom_groups = {
  -- Trim all trailing whitespace
  -- @ separater, double back slash for lua escape
  { 'BufWritePre', '*', ':%s@\\s\\+$@@e' },
  -- TODO: PR this change to vim-shfmt
  { 'BufWritePre', '*.bats', 'Shfmt -ln bats' },
}

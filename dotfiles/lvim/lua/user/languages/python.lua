-- Modified: https://github.com/LunarVim/starter.lvim/blob/python-ide/config.lua
-- :MasonInstall debugpy
--
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {{command = "black", filetypes = {"python"}}}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    {command = "flake8", filetypes = {"python"}},
    {command = "pylint", filetypes = {"python"}} --
}

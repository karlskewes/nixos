-- Modified: https://github.com/LunarVim/starter.lvim/blob/python-ide/config.lua
-- :MasonInstall debugpy
--
vim.list_extend(lvim.plugins, {{"mfussenegger/nvim-dap-python"}})

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {{command = "black", filetypes = {"python"}}}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    {command = "flake8", filetypes = {"python"}},
    {command = "pylint", filetypes = {"python"}} --
}

---@diagnostic disable: missing-parameter -- params 2 & 3 are optional
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
pcall(function()
    require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
end)

-- Default of unittest can struggle to find modules but pytest seems reliable.
pcall(function() require("dap-python").test_runner = "pytest" end)

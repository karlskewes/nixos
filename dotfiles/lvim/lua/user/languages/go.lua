-- Modified: https://github.com/LunarVim/starter.lvim/tree/go-ide
-- :MasonInstall delve gopls golangci-lint-langserver goimports gofumpt gomodifytags gotests impl staticcheck
lvim.builtin.treesitter.ensure_installed = {"go", "gomod", "gosum", "gowork"}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {command = "goimports", filetypes = {"go"}},
    {command = "gofumpt", filetypes = {"go"}}
}

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, {"gopls"})

lsp_manager.setup("gopls", {
    on_attach = function(client, bufnr)
        require("lvim.lsp").common_on_attach(client, bufnr)
        local _, _ = pcall(vim.lsp.codelens.refresh)
    end,
    on_init = require("lvim.lsp").common_on_init,
    capabilities = require("lvim.lsp").common_capabilities(),
    settings = {
        gopls = {
            usePlaceholders = true,
            gofumpt = true,
            codelenses = {
                generate = false,
                gc_details = true,
                test = true,
                tidy = true
            }
        }
    }
})

-- Modified: https://github.com/ChristianChiarulli/lvim/blob/master/lua/user/lsp/languages/js-ts.lua
-- :MasonInstall eslint_d js-debug-adapter prettier typescript-language-server
--
lvim.builtin.treesitter.ensure_installed = {
    "css", "html", "javascript", "typescript", "tsx"
}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {
        command = "prettier",
        filetypes = {
            "javascript", "typescript", "javascriptreact", "typescriptreact",
            "css"
        }
    }
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    {
        command = "eslint_d",
        filetypes = {
            "javascript", "javascriptreact", "typescript", "typescriptreact",
            "vue"
        }
    }
}

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, {
    "cssls", -- handled by tailwindcss
    "tsserver" -- ?
})

local capabilities = require("lvim.lsp").common_capabilities()

require("typescript").setup {
    -- disable_commands = false, -- prevent the plugin from creating Vim commands
    debug = false, -- enable debug logging for commands
    go_to_source_definition = {
        fallback = true -- fall back to standard LSP definition on failure
    },
    server = { -- pass options to lspconfig's setup method
        on_attach = require("lvim.lsp").common_on_attach,
        on_init = require("lvim.lsp").common_on_init,
        capabilities = capabilities,
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayEnumMemberValueHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayFunctionParameterTypeHints = false,
                    includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayVariableTypeHints = true
                }
            }
        }
    }
}

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {{command = "lua-format", filetypes = {"lua"}}}

-- fix Lua with manual installation
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers,
                {"sumneko_lua"})
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
require("lvim.lsp.manager").setup("sumneko_lua", {
    cmd = {
        -- TODO: support home-manager only lua-language server under /home/..
        "/etc/profiles/per-user/karl/bin/lua-language-server", "-E",
        "/etc/profiles/per-user/karl/share/lua-language-server/main.lua"
    },
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {enable = false}
        }
    }
})

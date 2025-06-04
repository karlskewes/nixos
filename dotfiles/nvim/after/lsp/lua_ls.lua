local lua_runtime_path = vim.split(package.path, ';')
table.insert(lua_runtime_path, 'lua/?.lua')
table.insert(lua_runtime_path, 'lua/?/init.lua')

---@type vim.lsp.Config
local config = {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
        disable = { 'missing-fields' },
      },
      format = { enable = true },
      runtime = {
        version = 'LuaJIT', -- Neovim
        -- find Lua modules same way as Neovim (see `:h lua-module-load`)
        path = lua_runtime_path,
      },
      telemetry = { enable = false },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME, -- Neovim runtime files
          --   -- any additional paths
          --   -- '${3rd}/luv/library'
          --   -- '${3rd}/busted/library'
        },
      },
    },
  },
}

return config

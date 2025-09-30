---@type vim.lsp.Config
local config = {
  ['nil'] = {
    nix = {
      flake = {
        -- download flake inputs for completion automatically instead of prompting.
        autoArchive = true,
      },
    },
  },
}

return config

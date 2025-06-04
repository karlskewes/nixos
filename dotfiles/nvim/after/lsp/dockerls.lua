---@type vim.lsp.Config
local config = {
  cmd = { 'docker-language-server', 'start', '--stdio' },
}

return config

--- get_current_gomod returns the current Go module for use in `goimports -local <here>`.
---@return string
local get_current_gomod = function()
  local module = '' -- gopls default

  if vim.fn.executable('go') ~= 1 then
    return module
  end

  local list_module = vim.fn.trim(vim.fn.system('go list -m'))
  if vim.v.shell_error ~= 0 then
    return module
  end

  module = list_module:gsub('\n', ',')

  return module
end

---@type vim.lsp.Config
local config = {
  init_options = {
    ['local'] = get_current_gomod(), -- keyword cannot be used as name workaround.
    usePlaceholders = true,
    codelenses = {
      generate = true,
      gc_details = true,
      test = true,
      tidy = true,
    },
    gofumpt = true,
    staticcheck = true,
  },
}

return config

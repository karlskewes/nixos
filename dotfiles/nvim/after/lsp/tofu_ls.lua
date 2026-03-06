---@type vim.lsp.Config
local config = {
  -- Use standard terraform filetypes
  filetypes = { 'terraform', 'terraform-vars' },
  -- Tell LSP server to treat terraform files as opentofu
  get_language_id = function(_, filetype)
    if filetype == 'terraform' then
      return 'terraform'
    end
    if filetype == 'terraform-vars' then
      return 'terraform-vars'
    end
    return filetype
  end,
}

return config

---@type vim.lsp.Config
local config = {
  filetypes = {
    'templ',
    'astro',
    'html',
    'css',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        templ = 'html',
      },
    },
  },
}

return config

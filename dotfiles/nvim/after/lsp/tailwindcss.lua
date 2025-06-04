---@type vim.lsp.Config
local config = {
  filetypes = { 'templ', 'astro', 'javascript', 'typescript', 'react' },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        templ = 'html',
      },
    },
  },
}

return config

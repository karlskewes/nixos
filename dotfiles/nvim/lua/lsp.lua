-- LSP Configuration & Plugins
vim.diagnostic.config({
  virtual_text = {
    source = true, -- "if_many"
  },
  signs = true,
  update_in_insert = false, -- too noisy, signature help and completion enough.
  underline = true,
  severity_sort = true,
  float = {
    source = true, -- "if_many"
  },
})

--  This function gets run when an LSP connects to a particular buffer.
local lsp_on_attach = function(args)
  local bufnr = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client == nil then
    return
  end

  local fzf = require('fzf-lua')

  vim.keymap.set('n', 'gd', fzf.lsp_definitions, { buffer = bufnr, desc = '[G]oto [D]efinition' })
  vim.keymap.set(
    'n',
    'gD',
    vim.lsp.buf.declaration,
    { buffer = bufnr, desc = '[G]oto [D]eclaration' }
  )
  vim.keymap.set(
    'n',
    'gI',
    fzf.lsp_implementations,
    { buffer = bufnr, desc = '[G]oto [I]mplementation - Default: [gri]' }
  )
  vim.keymap.set(
    'n',
    'gl',
    vim.diagnostic.open_float,
    { buffer = bufnr, desc = '[G]oto [L]ine diagnostic' }
  )
  vim.keymap.set(
    'n',
    '<leader>la',
    vim.lsp.buf.code_action,
    { buffer = bufnr, desc = '[L]SP Code [A]ction - Default: [gra]' }
  )
  vim.keymap.set(
    'n',
    '<leader>lc',
    fzf.lsp_incoming_calls,
    { desc = 'LSP: [S]earch Incoming [c]alls' }
  )
  vim.keymap.set(
    'n',
    '<leader>lC',
    fzf.lsp_outgoing_calls,
    { desc = 'LSP: [S]earch Outgoing [C]alls' }
  )
  vim.keymap.set(
    'n',
    '<leader>ld',
    vim.diagnostic.setloclist,
    { buffer = bufnr, desc = '[L]SP [D]iagnostics list' }
  )
  vim.keymap.set(
    'n',
    '<leader>lt',
    fzf.lsp_typedefs,
    { buffer = bufnr, desc = '[L]SP Type [D]efinition' }
  )
  vim.keymap.set('n', '<leader>lh', function()
    local enabled = vim.lsp.inlay_hint.is_enabled()
    vim.lsp.inlay_hint.enable(not enabled)
  end, {
    buffer = bufnr,
    desc = '[L]SP Inlay [H]ints Toggle',
  })
  vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { buffer = bufnr, desc = '[L]SP [F]ormat' })
  vim.keymap.set('n', '<leader>li', '<Cmd>LspInfo<CR>', { buffer = bufnr, desc = '[L]SP [I]nfo' })
  vim.keymap.set(
    'n',
    '<leader>ll',
    vim.diagnostic.open_float,
    { buffer = bufnr, desc = '[L]SP [L]ine Diagnostics' }
  )
  vim.keymap.set(
    'n',
    '<leader>lr',
    vim.lsp.buf.rename,
    { buffer = bufnr, desc = '[L]SP [R]ename - Default: [grn]' }
  )
  vim.keymap.set(
    'n',
    '<leader>lR',
    fzf.lsp_references,
    { buffer = bufnr, desc = '[L]SP [R]eferences - Default: [grr]' }
  )
  vim.keymap.set('n', '<leader>ls', function()
    -- methods in Go can get truncated, width based on vertical split in terminal.
    fzf.lsp_document_symbols({ symbol_width = 60 })
  end, { buffer = bufnr, desc = '[L]SP Document [S]ymbols - Default: [g0]' })
  vim.keymap.set(
    'n',
    '<leader>lS',
    fzf.lsp_live_workspace_symbols,
    { buffer = bufnr, desc = '[L]SP Workspace [S]ymbols' }
  )

  -- See `:help K` for why this keymap
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = 'Hover Documentation' })
  vim.keymap.set(
    'n',
    '<leader>K',
    vim.lsp.buf.signature_help,
    { buffer = bufnr, desc = 'Signature Documentation' }
  )
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = lsp_on_attach,
})

-- blink-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities =
  vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())

-- Extend all LSP servers with custom capabilities.
vim.lsp.config('*', { capabilities = capabilities })

-- Enable the following language servers:
-- default config from nvim-lspconfig
-- extra config via ./lsp/*.lua
vim.lsp.enable('bashls')
vim.lsp.enable('buf_ls')
vim.lsp.enable('dockerls')
vim.lsp.enable('eslint')
vim.lsp.enable('gopls')
vim.lsp.enable('golangci_lint_ls')
vim.lsp.enable('html')
-- vim.lsp.enable("htmx") -- Both htmx and htmx2 troublesome
vim.lsp.enable('nil_ls')
vim.lsp.enable('pyright')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('sqls')
vim.lsp.enable('tailwindcss')
vim.lsp.enable('tofu_ls')
-- vim.lsp.enable('ts_ls') --
vim.lsp.enable('vue_ls')
-- vim.lsp.enable('vue-language-server') -- see ts_ls comment above.
vim.lsp.enable('yamlls')
vim.lsp.enable('lua_ls')

-- Unused and not migrated and tested language servers.
-- local servers = {
-- htmx = {
--   -- cmd = 'htmx-lsp2', -- TODO: vet code
--   cmd = 'htmx-lsp', -- https://github.com/ThePrimeagen/htmx-lsp/issues/53
--   filetypes = { 'html', 'templ' },
-- },
-- ts_ls = {
--   -- HACK: config defined in neovim.nix for javascript library nix store path.
--   --       see ~/.config/nvim/lua/ts_ls.lua for rendered file.
--   -- https://github.com/vuejs/language-tools
-- },
-- vue-language-server, see ts_ls comment above.
-- }

-- ui notifications and lsp progress messages.
require('fidget').setup({})

-- neovim setup for init.lua and plugin development, completion for nvim lua api.
require('neodev').setup()

-- completion
require('blink.cmp').setup({
  completion = {
    -- Show documentation when selecting a completion item
    documentation = { auto_show = true, auto_show_delay_ms = 500 },

    -- Display a preview of the selected item on the current line
    ghost_text = { enabled = true },
  },
  -- Experimental signature help support
  signature = { enabled = true },
})

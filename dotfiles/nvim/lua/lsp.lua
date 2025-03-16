-- LSP Configuration & Plugins
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false, -- too noisy, signature help and completion enough.
  underline = true,
  severity_sort = true,
  float = true,
})

--  This function gets run when an LSP connects to a particular buffer.
local lsp_on_attach = function(_, bufnr)
  local tsb = require('telescope.builtin')
  vim.keymap.set('n', 'gd', tsb.lsp_definitions, { buffer = bufnr, desc = '[G]oto [D]efinition' })
  vim.keymap.set(
    'n',
    'gD',
    vim.lsp.buf.declaration,
    { buffer = bufnr, desc = '[G]oto [D]eclaration' }
  )
  vim.keymap.set(
    'n',
    'gI',
    tsb.lsp_implementations,
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
    '<leader>ld',
    vim.diagnostic.setloclist,
    { buffer = bufnr, desc = '[L]SP [D]iagnostics list' }
  )
  vim.keymap.set(
    'n',
    '<leader>lD',
    tsb.lsp_type_definitions,
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
    tsb.lsp_references,
    { buffer = bufnr, desc = '[L]SP [R]eferences - Default: [grr]' }
  )
  vim.keymap.set('n', '<leader>ls', function()
    -- methods in Go can get truncated, width based on vertical split in terminal.
    tsb.lsp_document_symbols({ symbol_width = 60 })
  end, { buffer = bufnr, desc = '[L]SP Document [S]ymbols - Default: [g0]' })
  vim.keymap.set(
    'n',
    '<leader>lS',
    tsb.lsp_dynamic_workspace_symbols,
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

local lspconfig = require('lspconfig')

-- blink-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities =
  vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
local lua_runtime_path = vim.split(package.path, ';')
table.insert(lua_runtime_path, 'lua/?.lua')
table.insert(lua_runtime_path, 'lua/?/init.lua')

-- TODO: fetch go.mod path and then pass to goimports -local <here> to sort imports.
-- local get_current_gomod = function()
--   if vim.fn.executable('go') ~= 1 then
--     return
--   end
--
--   local module = vim.fn.trim(vim.fn.system('go list -m'))
--   if vim.v.shell_error ~= 0 then
--     return
--   end
--   module = module:gsub('\n', ',')
-- end

-- Enable the following language servers, config passed to server config `settings` field.
local servers = {
  bashls = {},
  buf_ls = {},
  dockerls = {},
  eslint = {},
  gopls = {
    settings = {
      -- local = get_current_gomod,
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
  },
  golangci_lint_ls = {},
  html = {
    filetypes = { 'html', 'templ' },
  },
  -- htmx = {
  --   -- cmd = 'htmx-lsp2', -- TODO: vet code
  --   cmd = 'htmx-lsp', -- https://github.com/ThePrimeagen/htmx-lsp/issues/53
  --   filetypes = { 'html', 'templ' },
  -- },
  nil_ls = {},
  pyright = {},
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        -- $ rust-analyzer --print-config-schema
        cargo = {
          features = 'all',
        },
        check = {
          features = 'all',
          command = 'clippy',
          extraArgs = {
            '--',
            '--no-deps',
            -- https://doc.rust-lang.org/stable/clippy/index.html
            '-Dclippy::complexity',
            '-Dclippy::correctness',
            '-Wclippy::all',
            '-Wclippy::cargo',
            '-Wclippy::pedantic',
            '-Wclippy::nursery',
          },
        },
        procMacro = {
          enable = true,
        },
      },
    },
  },
  sqlls = {},
  tailwindcss = {
    filetypes = { 'templ', 'astro', 'javascript', 'typescript', 'react' },
    settings = {
      tailwindCSS = {
        includeLanguages = {
          templ = 'html',
        },
      },
    },
  },
  -- ts_ls = {
  --   -- HACK: config defined in neovim.nix for javascript library nix store path.
  --   --       see ~/.config/nvim/lua/ts_ls.lua for rendered file.
  --   -- https://github.com/vuejs/language-tools
  -- },
  volar = {
    -- vue-language-server, see ts_ls comment above.
  },
  yamlls = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
          disable = { 'missing-fields' },
        },
        format = { enable = true },
        runtime = {
          version = 'luajit',
          path = lua_runtime_path,
        },
        telemetry = { enable = false },
        workspace = {
          checkthirdparty = false,
          -- make the server aware of neovim runtime files
          library = vim.api.nvim_get_runtime_file('', true),
        },
      },
    },
  },
}

local setup_handlers = function()
  for k, v in pairs(servers) do
    -- override/extend any server with custom capabilities.
    v.capabilities = vim.tbl_deep_extend('force', {}, capabilities, v.capabilities or {})
    v.on_attach = lsp_on_attach

    lspconfig[k].setup(v)
  end
end
setup_handlers()

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

-- LSP Configuration & Plugins
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
  vim.keymap.set(
    'n',
    '<leader>ls',
    tsb.lsp_document_symbols,
    { buffer = bufnr, desc = '[L]SP Document [S]ymbols - Default: [g0]' }
  )
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
-- tangentially related.
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = true,
  underline = true,
  severity_sort = false,
  float = true,
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities =
  vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

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
  html = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
  -- htmx = {}, -- TODO
  nil_ls = {},
  pyright = {},
  rust_analyzer = {},
  sqlls = {},
  -- tailwindcss = {}, -- TODO
  ts_ls = {
    init_options = {
      plugins = {
        {
          name = '@vue/typescript-plugin',
          location = 'vue-language-server',
          languages = { 'vue' },
        },
      },
    },
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  },
  -- vuels = {
  --   cmd = { 'vue-language-server', '--stdio' },
  --   -- filetypes = {},
  -- },
  volar = {
    -- filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    -- init_options = {
    --   vue = {
    --     hybridMode = false,
    --   },
    -- },
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

-- autocompletion replacement for hrsh7th/cmp-nvim-lsp-signature-help
-- broken, triggers after ",": https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/issues/41
-- 'hrsh7th/cmp-nvim-lsp-signature-help',
-- require('lsp_signature').setup({})
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if vim.tbl_contains({ 'null-ls' }, client.name) then -- blacklist lsp
      return
    end
    require('lsp_signature').on_attach({
      -- ... setup options here ...
    }, bufnr)
  end,
})

-- autocompletion
-- todo: is this event based triggering even needed? seems fast enough?
-- event = { 'insertenter', 'cmdlineenter' },
-- dependencies = {
--   -- snippet engine & its associated nvim-cmp source
--   'l3mon4d3/luasnip',
--   'saadparwaiz1/cmp_luasnip',
--
--
-- see `:help cmp`
local cmp = require('cmp')
-- todo: consider snippet source, these or write own? mini.snippets?
-- local luasnip = require('luasnip')
-- require('luasnip.loaders.from_vscode').lazy_load()
-- luasnip.config.setup({})

cmp.setup({
  -- snippet = {
  --   expand = function(args)
  --     luasnip.lsp_expand(args.body)
  --   end,
  -- },
  completion = { completeopt = 'menu,menuone,noinsert' },
  mapping = cmp.mapping.preset.insert({
    ['<c-n>'] = cmp.mapping.select_next_item(),
    ['<c-p>'] = cmp.mapping.select_prev_item(),
    ['<c-b>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-space>'] = cmp.mapping.complete(),
    ['<c-y>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.replace,
      select = true,
    }),
    ['<c-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      -- elseif luasnip.expand_or_locally_jumpable() then
      --   luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<c-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      -- elseif luasnip.locally_jumpable(-1) then
      --   luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    -- { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    -- FIXME: Broken, use ray-x/lsp_signature for now
    -- {name = 'nvim_lsp_signature_help'},
  },
})

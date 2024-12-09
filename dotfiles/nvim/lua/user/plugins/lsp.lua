return {
  -- LSP Configuration & Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        -- bridges mason.nvim with the lspconfig plugin.
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
          {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            config = true,
          },
        },
        config = function()
          --  This function gets run when an LSP connects to a particular buffer.
          local lsp_on_attach = function(_, bufnr)
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
            vim.keymap.set('n', '<leader>lh', function()
              local enabled = vim.lsp.inlay_hint.is_enabled()
              vim.lsp.inlay_hint.enable(not enabled)
            end, {
              buffer = bufnr,
              desc = '[L]SP Inlay [H]ints Toggle',
            })
            vim.keymap.set(
              'n',
              '<leader>lf',
              vim.lsp.buf.format,
              { buffer = bufnr, desc = '[L]SP [F]ormat' }
            )
            vim.keymap.set(
              'n',
              '<leader>li',
              '<Cmd>LspInfo<CR>',
              { buffer = bufnr, desc = '[L]SP [I]nfo' }
            )
            vim.keymap.set(
              'n',
              '<leader>lr',
              vim.lsp.buf.rename,
              { buffer = bufnr, desc = '[L]SP [R]ename - Default: [grn]' }
            )
            vim.keymap.set(
              'n',
              'gd',
              require('telescope.builtin').lsp_definitions,
              { buffer = bufnr, desc = '[G]oto [D]efinition' }
            )
            vim.keymap.set(
              'n',
              'gD',
              vim.lsp.buf.declaration,
              { buffer = bufnr, desc = '[G]oto [D]eclaration' }
            )
            vim.keymap.set(
              'n',
              'gl',
              vim.diagnostic.open_float,
              { buffer = bufnr, desc = '[G]oto [L]ine diagnostic' }
            )
            vim.keymap.set(
              'n',
              '<leader>lR',
              require('telescope.builtin').lsp_references,
              { buffer = bufnr, desc = '[L]SP [R]eferences - Default: [grr]' }
            )
            vim.keymap.set(
              'n',
              'gI',
              require('telescope.builtin').lsp_implementations,
              { buffer = bufnr, desc = '[G]oto [I]mplementation' }
            )
            vim.keymap.set(
              'n',
              '<leader>lD',
              require('telescope.builtin').lsp_type_definitions,
              { buffer = bufnr, desc = '[L]SP Type [D]efinition' }
            )
            vim.keymap.set(
              'n',
              '<leader>ls',
              require('telescope.builtin').lsp_document_symbols,
              { buffer = bufnr, desc = '[L]SP Document [S]ymbols' }
            )
            vim.keymap.set(
              'n',
              '<leader>lS',
              require('telescope.builtin').lsp_dynamic_workspace_symbols,
              { buffer = bufnr, desc = '[L]SP Workspace [S]ymbols' }
            )

            -- See `:help K` for why this keymap
            vim.keymap.set(
              'n',
              'K',
              vim.lsp.buf.hover,
              { buffer = bufnr, desc = 'Hover Documentation' }
            )
            vim.keymap.set(
              'n',
              '<leader>K',
              vim.lsp.buf.signature_help,
              { buffer = bufnr, desc = 'Signature Documentation' }
            )
          end

          local lua_runtime_path = vim.split(package.path, ';')
          table.insert(lua_runtime_path, 'lua/?.lua')
          table.insert(lua_runtime_path, 'lua/?/init.lua')

          local get_current_gomod = function()
            if vim.fn.executable('go') ~= 1 then
              return
            end

            local module = vim.fn.trim(vim.fn.system('go list -m'))
            if vim.v.shell_error ~= 0 then
              return
            end
            module = module:gsub('\n', ',')
          end

          -- Enable the following language servers, config passed to server config `settings` field.
          local servers = {
            bashls = {},
            buf_ls = {},
            dockerls = {},
            eslint = {},
            -- gopls = {}, -- Managed by ray-x/go.nvim
            golangci_lint_ls = {},
            html = {},
            -- html = { filetypes = { 'html', 'twig', 'hbs'} },
            htmx = {},
            nil_ls = {},
            pyright = {},
            rust_analyzer = {
              cmd = {
                '/etc/profiles/per-user/karl/bin/rust-analyzer',
              },
            },
            sqlls = {},
            tailwindcss = {},
            tsserver = {},
            vuels = {},
            yamlls = {},
            lua_ls = {
              -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
              cmd = {
                -- TODO: support home-manager only lua-language server under /home/..
                '/etc/profiles/per-user/karl/bin/lua-language-server',
                '-E',
                '/etc/profiles/per-user/karl/share/lua-language-server/main.lua',
              },
              Lua = {
                diagnostics = {
                  globals = { 'vim' },
                  disable = { 'missing-fields' },
                },
                format = { enable = true },
                runtime = {
                  version = 'LuaJIT',
                  path = lua_runtime_path,
                },
                telemetry = { enable = false },
                workspace = {
                  checkThirdParty = false,
                  -- Make the server aware of Neovim runtime files
                  library = vim.api.nvim_get_runtime_file('', true),
                },
              },
            },
          }

          -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities = vim.tbl_deep_extend(
            'force',
            capabilities,
            require('cmp_nvim_lsp').default_capabilities()
          )

          -- Ensure the servers above are installed
          local mason_lspconfig = require('mason-lspconfig')

          mason_lspconfig.setup({
            ensure_installed = {},
            automatic_installation = { exclude = { 'lua_ls', 'rust_analyzer' } },
          })

          mason_lspconfig.setup_handlers({
            function(server_name)
              -- some language servers depend on system libraries so we must use
              -- NixOS installed versions.
              if server_name == 'lua_ls' then
                require('lspconfig')['lua_ls'].setup({
                  capabilities = capabilities,
                  cmd = servers['lua_ls'].cmd,
                  on_attach = lsp_on_attach,
                  settings = servers['lua_ls'],
                  filetypes = (servers['lua_ls'] or {}).filetypes,
                })
              elseif server_name == 'rust_analyzer' then
                require('lspconfig')['rust_analyzer'].setup({
                  capabilities = capabilities,
                  cmd = servers['rust_analyzer'].cmd,
                  on_attach = lsp_on_attach,
                  settings = servers['rust_analyzer'],
                  filetypes = (servers['rust_analyzer'] or {}).filetypes,
                })
              else
                -- below sets up automatically installed servers.
                require('lspconfig')[server_name].setup({
                  capabilities = capabilities,
                  on_attach = lsp_on_attach,
                  settings = servers[server_name],
                  filetypes = (servers[server_name] or {}).filetypes,
                })
              end
            end,
          })

          vim.keymap.set('n', '<leader>pm', '<cmd>Mason<CR>', { desc = 'Mason' })
        end,
      },
      {
        -- UI notifications and LSP progress messages.
        'j-hui/fidget.nvim',
        opts = {},
      },
      {
        -- Neovim setup for init.lua and plugin development, completion for nvim lua API.
        'folke/neodev.nvim',
        opts = {},
      },
    },
  },
  {
    -- Autocompletion replacement for hrsh7th/cmp-nvim-lsp-signature-help
    'ray-x/lsp_signature.nvim',
    event = 'VeryLazy',
    opts = {},
    config = function(_, opts)
      require('lsp_signature').setup(opts)
    end,
  },
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      -- broken, triggers after ",": https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/issues/41
      -- 'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-y>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ['<C-k>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-j>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
          -- FIXME: Broken, use ray-x/lsp_signature for now
          -- {name = 'nvim_lsp_signature_help'},
        },
      })
    end,
  },
}

-- :MasonInstall delve gopls golangci-lint-langserver goimports gofumpt gomodifytags gotests impl staticcheck
return {
    -- LSP Configuration & Plugins
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            {
                'williamboman/mason-lspconfig.nvim',
                dependencies = {
                    {
                        -- Automatically install LSPs to stdpath for neovim
                        'williamboman/mason.nvim',
                        config = function()
                            require("mason").setup {}
                        end

                    }
                },
                config = function()
                    --  This function gets run when an LSP connects to a particular buffer.
                    local lsp_on_attach = function(_, bufnr)
                        -- Easily define mappings specific for LSP related items.
                        local nmap = function(keys, func, desc)
                            if desc then
                                desc = 'LSP: ' .. desc
                            end

                            vim.keymap.set('n', keys, func,
                                           {buffer = bufnr, desc = desc})
                        end

                        nmap('<leader>la', vim.lsp.buf.code_action,
                             'Code [A]ction')
                        nmap('<leader>ld', vim.diagnostic.setloclist,
                             '[D]iagnostics list')
                        nmap('<leader>lf', vim.lsp.buf.format, "[F]ormat")
                        nmap('<leader>li', "<Cmd>LspInfo<CR>", '[I]nfo')
                        nmap('<leader>lr', vim.lsp.buf.rename, '[R]ename')
                        nmap('gd', require('telescope.builtin').lsp_definitions,
                             '[G]oto [D]efinition')
                        nmap('gD', vim.lsp.buf.declaration,
                             '[G]oto [D]eclaration')
                        nmap('gl', vim.diagnostic.open_float,
                             '[G]oto [L]ine diagnostic')
                        nmap('gr', require('telescope.builtin').lsp_references,
                             '[G]oto [R]eferences')
                        nmap('gI',
                             require('telescope.builtin').lsp_implementations,
                             '[G]oto [I]mplementation')
                        nmap('<leader>lD',
                             require('telescope.builtin').lsp_type_definitions,
                             'Type [D]efinition')
                        nmap('<leader>ls',
                             require('telescope.builtin').lsp_document_symbols,
                             'Document [S]ymbols')
                        nmap('<leader>lS',
                             require('telescope.builtin').lsp_dynamic_workspace_symbols,
                             'Workspace [S]ymbols')

                        -- See `:help K` for why this keymap
                        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
                        nmap('<leader>K', vim.lsp.buf.signature_help,
                             'Signature Documentation')

                        -- Create a command `:Format` local to the LSP buffer
                        vim.api.nvim_buf_create_user_command(bufnr, 'Format',
                                                             function(_)
                            vim.lsp.buf.format()
                        end, {desc = 'Format current buffer with LSP'})
                    end

                    -- TODO, why call setup here and then again later, simplify.
                    require('mason-lspconfig').setup()

                    -- fix Lua with manual installation
                    -- TODO, fix lua language server, see old lunarvim config.
                    local lua_runtime_path = vim.split(package.path, ';')
                    table.insert(lua_runtime_path, "lua/?.lua")
                    table.insert(lua_runtime_path, "lua/?/init.lua")

                    -- Enable the following language servers
                    -- Any additional override configuration will be passed to the `settings` field of
                    -- the server config.
                    -- Override default filetypes by defining the property 'filetypes' on the map in question.
                    local servers = {
                        bashls = {},
                        bufls = {},
                        dockerls = {},
                        eslint = {},
                        gopls = {
                            usePlaceholders = true,
                            codelenses = {
                                generate = false,
                                gc_details = true,
                                test = true,
                                tidy = true
                            },
                            gofumpt = true,
                            staticcheck = true
                        },
                        -- golangci_lint_ls = {}, -- conflicts with gopls
                        html = {},
                        -- html = { filetypes = { 'html', 'twig', 'hbs'} },
                        htmx = {},
                        pyright = {},
                        rnix = {},
                        rust_analyzer = {},
                        sqlls = {},
                        tailwindcss = {},
                        tsserver = {},
                        vuels = {},
                        yamlls = {},
                        lua_ls = {
                            -- TODO: fix - https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_l
                            cmd = {
                                -- TODO: support home-manager only lua-language server under /home/..
                                "/etc/profiles/per-user/karl/bin/lua-language-server",
                                "-E",
                                "/etc/profiles/per-user/karl/share/lua-language-server/main.lua"
                            },
                            Lua = {
                                workspace = {checkThirdParty = false},
                                telemetry = {enable = false},
                                -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                                -- diagnostics = { disable = { 'missing-fields' } },
                                runtime = {
                                    version = 'LuaJIT',
                                    path = lua_runtime_path
                                },
                                diagnostics = {
                                    globals = {'vim'}
                                    -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                                    -- disable = { 'missing-fields' }
                                },
                                workspace = {
                                    -- Make the server aware of Neovim runtime files
                                    library = vim.api.nvim_get_runtime_file("",
                                                                            true)
                                },
                                telemetry = {enable = false}
                            }
                        }
                    }

                    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
                    local capabilities = vim.lsp.protocol
                                             .make_client_capabilities()
                    capabilities = require('cmp_nvim_lsp').default_capabilities(
                                       capabilities)

                    -- Ensure the servers above are installed
                    local mason_lspconfig = require 'mason-lspconfig'

                    -- TODO, remove earlier setup call.
                    mason_lspconfig.setup {
                        ensure_installed = vim.tbl_keys(servers)
                    }

                    mason_lspconfig.setup_handlers {
                        function(server_name)
                            require('lspconfig')[server_name].setup {
                                capabilities = capabilities,
                                on_attach = lsp_on_attach,
                                settings = servers[server_name],
                                filetypes = (servers[server_name] or {}).filetypes
                            }
                        end
                    }

                    vim.keymap.set("n", "<leader>pm", "<cmd>Mason<CR>",
                                   {desc = "Mason"})

                end
            }, -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            {'j-hui/fidget.nvim', opts = {}},
            -- Additional lua configuration, makes nvim stuff amazing!
            {
                'folke/neodev.nvim',
                config = function() require('neodev').setup() end
            }
        }
    }, {
        -- Signature hints
        "ray-x/lsp_signature.nvim",
        event = "BufRead",
        config = function()
            require"lsp_signature".on_attach({fix_pos = true})
        end
    }, {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-buffer', 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-path',

            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets'
        },
        config = function()
            -- See `:help cmp`
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            require('luasnip.loaders.from_vscode').lazy_load()
            luasnip.config.setup {}

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                completion = {completeopt = 'menu,menuone,noinsert'},
                mapping = cmp.mapping.preset.insert {
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete {},
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true
                    },
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, {'i', 's'}),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, {'i', 's'})
                },
                sources = {
                    {name = 'nvim_lsp'}, {name = 'luasnip'}, {name = 'buffer'},
                    {name = 'path'}
                }
            }

        end
    }
}

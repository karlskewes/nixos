return {
    -- LSP Configuration & Plugins
    {
        'neovim/nvim-lspconfig',
        config = function()
            --  Use :FormatToggle to toggle autoformatting on or off
            local format_is_enabled = true
            vim.api.nvim_create_user_command('FormatToggle', function()
                format_is_enabled = not format_is_enabled
                print('Setting autoformatting to: ' ..
                          tostring(format_is_enabled))
            end, {})

            -- Create an augroup that is used for managing our formatting autocmds.
            --      We need one augroup per client to make sure that multiple clients
            --      can attach to the same buffer without interfering with each other.
            local _augroups = {}
            local get_augroup = function(client)
                if not _augroups[client.id] then
                    local group_name = 'lsp-format-' .. client.name
                    local id = vim.api.nvim_create_augroup(group_name,
                                                           {clear = true})
                    _augroups[client.id] = id
                end

                return _augroups[client.id]
            end

            -- Whenever an LSP attaches to a buffer, we will run this function.
            --
            -- See `:help LspAttach` for more information about this autocmd event.
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('lsp-attach-format',
                                                    {clear = true}),
                -- This is where we attach the autoformatting for reasonable clients
                callback = function(args)
                    local client_id = args.data.client_id
                    local client = vim.lsp.get_client_by_id(client_id)
                    local bufnr = args.buf

                    -- Only attach to clients that support document formatting
                    if not client.server_capabilities.documentFormattingProvider then
                        return
                    end

                    -- Tsserver usually works poorly. Sorry you work with bad languages
                    -- You can remove this line if you know what you're doing :)
                    if client.name == 'tsserver' then return end

                    -- Create an autocmd that will run *before* we save the buffer.
                    --  Run the formatting command for the LSP that has just attached.
                    vim.api.nvim_create_autocmd('BufWritePre', {
                        group = get_augroup(client),
                        buffer = bufnr,
                        callback = function()
                            if not format_is_enabled then
                                return
                            end

                            vim.lsp.buf.format {
                                async = false,
                                filter = function(c)
                                    return c.id == client.id
                                end
                            }
                        end
                    })
                end
            })
        end,

        dependencies = {
            {
                -- bridges mason.nvim with the lspconfig plugin.
                'williamboman/mason-lspconfig.nvim',
                dependencies = {
                    {
                        -- Automatically install LSPs to stdpath for neovim
                        'williamboman/mason.nvim',
                        config = true
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

                    local lua_runtime_path = vim.split(package.path, ';')
                    table.insert(lua_runtime_path, "lua/?.lua")
                    table.insert(lua_runtime_path, "lua/?/init.lua")

                    -- Enable the following language servers, config passed to server config `settings` field.
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
                        golangci_lint_ls = {},
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
                            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
                            cmd = {
                                -- TODO: support home-manager only lua-language server under /home/..
                                "/etc/profiles/per-user/karl/bin/lua-language-server",
                                "-E",
                                "/etc/profiles/per-user/karl/share/lua-language-server/main.lua"
                            },
                            Lua = {
                                workspace = {checkThirdParty = false},
                                telemetry = {enable = false},
                                diagnostics = {disable = {'missing-fields'}}, -- noisy
                                runtime = {
                                    version = 'LuaJIT',
                                    path = lua_runtime_path
                                },
                                diagnostics = {
                                    globals = {'vim'},
                                    disable = {'missing-fields'}
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
                    capabilities = vim.tbl_deep_extend('force', capabilities,
                                                       require('cmp_nvim_lsp').default_capabilities())

                    -- Ensure the servers above are installed
                    local mason_lspconfig = require('mason-lspconfig')

                    mason_lspconfig.setup {
                        ensure_installed = {},
                        automatic_installation = {exclude = {"lua_ls"}}
                    }

                    mason_lspconfig.setup_handlers {
                        function(server_name)
                            -- below sets up automatically installed servers.
                            require('lspconfig')[server_name].setup {
                                capabilities = capabilities,
                                on_attach = lsp_on_attach,
                                settings = servers[server_name],
                                filetypes = (servers[server_name] or {}).filetypes
                            }

                            -- setup lua_language_server installed via OS, because mason version
                            -- doesn't work.
                            require("lspconfig")["lua_ls"].setup {
                                capabilities = capabilities,
                                cmd = servers["lua_ls"].cmd,
                                on_attach = lsp_on_attach,
                                settings = servers["lua_ls"],
                                filetypes = (servers["lua_ls"] or {}).filetypes
                            }
                        end
                    }

                    vim.keymap.set("n", "<leader>pm", "<cmd>Mason<CR>",
                                   {desc = "Mason"})
                end
            }, {
                -- UI notifications and LSP progress messages.
                'j-hui/fidget.nvim',
                opts = {}
            }, {
                -- Neovim setup for init.lua and plugin development, completion for nvim lua API.
                "folke/neodev.nvim",
                opts = {}
            }
        }
    }, {
        -- Autocompletion replacement for hrsh7th/cmp-nvim-lsp-signature-help
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {},
        config = function(_, opts) require'lsp_signature'.setup(opts) end
    }, {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        event = {"InsertEnter", "CmdlineEnter"},
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path',
            -- broken, triggers after ",": https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/issues/41
            -- 'hrsh7th/cmp-nvim-lsp-signature-help',

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
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-y>'] = cmp.mapping.confirm {
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
                    -- FIXME: Broken, use ray-x/lsp_signature for now
                    -- {name = 'nvim_lsp_signature_help'},
                }
            }
        end
    }
}

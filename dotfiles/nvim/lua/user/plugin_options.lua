-- [[ Configure Harpoon ]]
local harpoon = require("harpoon")
vim.keymap.set("n", "<C-a>", function() harpoon:list():append() end)
vim.keymap.set("n", "<C-l>",
               function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-n>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-m>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-,>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-.>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-J>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-K>", function() harpoon:list():next() end)

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
    -- Use the current buffer's path as the starting point for the git search
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir
    local cwd = vim.fn.getcwd()
    -- If the buffer is not associated with a file, return nil
    if current_file == '' then
        current_dir = cwd
    else
        -- Extract the directory from the current file's path
        current_dir = vim.fn.fnamemodify(current_file, ':h')
    end

    -- Find the Git root directory from the current file's path
    local git_root = vim.fn.systemlist('git -C ' ..
                                           vim.fn.escape(current_dir, ' ') ..
                                           ' rev-parse --show-toplevel')[1]
    if vim.v.shell_error ~= 0 then
        print 'Not a git repository. Searching on current working directory'
        return cwd
    end
    return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
    local git_root = find_git_root()
    if git_root then
        require('telescope.builtin').live_grep {search_dirs = {git_root}}
    end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles,
               {desc = '[?] Find recently opened files'})
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers,
               {desc = '[ ] Find existing buffers'})
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require(
                                                               'telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false
    })
end, {desc = '[/] Fuzzily search in current buffer'})

local function telescope_live_grep_open_files()
    require('telescope.builtin').live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files'
    }
end

vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files,
               {desc = '[S]earch [/] in Open Files'})
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin,
               {desc = '[S]earch [S]elect Telescope'})
vim.keymap.set('n', '<leader>sF', require('telescope.builtin').git_files,
               {desc = '[S]earch git [F]iles'})
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files,
               {desc = '[S]earch [F]iles'})
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags,
               {desc = '[S]earch [H]elp'})
vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps,
               {desc = '[S]earch [K]eymaps'})
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string,
               {desc = '[S]earch current [W]ord'})
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep,
               {desc = '[S]earch by [G]rep'})
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>',
               {desc = '[S]earch by [G]rep on Git Root'})
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics,
               {desc = '[S]earch [D]iagnostics'})
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume,
               {desc = '[S]earch [R]esume'})
vim.keymap.set('n', '<leader>sv', require('telescope.builtin').git_commits,
               {desc = '[S]earch [v]cs'})
vim.keymap.set('n', '<leader>sv<CR>', require('telescope.builtin').git_commits,
               {desc = '[S]earch [v]cs commits'})
vim.keymap.set('n', '<leader>svc', require('telescope.builtin').git_commits,
               {desc = '[S]earch [v]cs [c]ommits'})
vim.keymap.set('n', '<leader>svb', require('telescope.builtin').git_bcommits,
               {desc = '[S]earch [v]cs [b]uffer'})
vim.keymap.set('n', '<leader>svs', require('telescope.builtin').git_status,
               {desc = '[S]earch [v]cs status'})
vim.keymap.set('n', '<leader>svS', require('telescope.builtin').git_stash,
               {desc = '[S]earch [v]cs [S]tash'})

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
    require('nvim-treesitter.configs').setup {
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = {
            'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript',
            'typescript', 'vimdoc', 'vim', 'bash'
        },

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = false,

        highlight = {enable = true},
        indent = {enable = true},
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<c-space>',
                node_incremental = '<c-space>',
                scope_incremental = '<c-s>',
                node_decremental = '<M-space>'
            }
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ['aa'] = '@parameter.outer',
                    ['ia'] = '@parameter.inner',
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner'
                }
            },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer'
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer'
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer'
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer'
                }
            },
            swap = {
                enable = true,
                swap_next = {['<leader>a'] = '@parameter.inner'},
                swap_previous = {['<leader>A'] = '@parameter.inner'}
            }
        }
    }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local lsp_on_attach = function(_, bufnr)
    -- Easily define mappings specific for LSP related items.
    local nmap = function(keys, func, desc)
        if desc then desc = 'LSP: ' .. desc end

        vim.keymap.set('n', keys, func, {buffer = bufnr, desc = desc})
    end

    nmap('<leader>la', vim.lsp.buf.code_action, 'Code [A]ction')
    nmap('<leader>ld', vim.diagnostic.setloclist, '[D]iagnostics list')
    nmap('<leader>lf', vim.lsp.buf.format, "[F]ormat")
    nmap('<leader>li', "<Cmd>LspInfo<CR>", '[I]nfo')
    nmap('<leader>lr', vim.lsp.buf.rename, '[R]ename')
    nmap('gd', require('telescope.builtin').lsp_definitions,
         '[G]oto [D]efinition')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('gl', vim.diagnostic.open_float, '[G]oto [L]ine diagnostic')
    nmap('gr', require('telescope.builtin').lsp_references,
         '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations,
         '[G]oto [I]mplementation')
    nmap('<leader>lD', require('telescope.builtin').lsp_type_definitions,
         'Type [D]efinition')
    nmap('<leader>ls', require('telescope.builtin').lsp_document_symbols,
         'Document [S]ymbols')
    nmap('<leader>lS',
         require('telescope.builtin').lsp_dynamic_workspace_symbols,
         'Workspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<leader>K', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format',
                                         function(_) vim.lsp.buf.format() end, {
        desc = 'Format current buffer with LSP'
    })
end

-- document existing key chains
require('which-key').register {
    ['<leader>b'] = {name = '[B]uffer', _ = 'which_key_ignore'},
    ['<leader>d'] = {name = '[D]ebug', _ = 'which_key_ignore'},
    ['<leader>g'] = {name = '[G]it', _ = 'which_key_ignore'},
    ['<leader>h'] = {name = '[H]arpoon', _ = 'which_key_ignore'}, -- though bindings not under <leader>h atm.
    ['<leader>l'] = {name = '[L]sp', _ = 'which_key_ignore'},
    ['<leader>p'] = {name = '[P]lugins', _ = 'which_key_ignore'},
    ['<leader>s'] = {name = '[S]earch', _ = 'which_key_ignore'},
    ['<leader>t'] = {name = '[T]oggle', _ = 'which_key_ignore'}
}
-- register which-key VISUAL mode
-- required for visual <leader>gs (hunk stage) to work
require('which-key').register({
    ['<leader>'] = {name = 'VISUAL <leader>'},
    ['<leader>g'] = {'[G]it Hunk'}
}, {mode = 'v'})

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- fix Lua with manual installation
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
            "/etc/profiles/per-user/karl/bin/lua-language-server", "-E",
            "/etc/profiles/per-user/karl/share/lua-language-server/main.lua"
        },
        Lua = {
            workspace = {checkThirdParty = false},
            telemetry = {enable = false},
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
            runtime = {version = 'LuaJIT', path = lua_runtime_path},
            diagnostics = {
                globals = {'vim'}
                -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                -- disable = { 'missing-fields' }
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)
            },
            telemetry = {enable = false}
        }
    }
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {ensure_installed = vim.tbl_keys(servers)}

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

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
    snippet = {expand = function(args) luasnip.lsp_expand(args.body) end},
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
    sources = {{name = 'nvim_lsp'}, {name = 'luasnip'}, {name = 'path'}}
}

-- [[ Plugins ]]
vim.keymap.set("n", "<leader>pl", "<cmd>Lazy<CR>", {desc = "Lazy"})
vim.keymap.set("n", "<leader>pm", "<cmd>Mason<CR>", {desc = "Mason"})


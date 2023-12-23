-- See the kickstart.nvim README for more information
-- [[ Configure plugins ]]
local harpoon -- enables access to harpoon for key mapping as it doesn't get loaded into global scope.

return {
    -- Git related plugins
    'tpope/vim-fugitive', 'tpope/vim-rhubarb',

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            {'j-hui/fidget.nvim', opts = {}},

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim'
        }
    }, {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-path',

            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets'
        }
    }, -- Useful plugin to show you pending keybinds.
    {'folke/which-key.nvim', opts = {}}, {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = {text = '+'},
                change = {text = '~'},
                delete = {text = '_'},
                topdelete = {text = '‾'},
                changedelete = {text = '~'}
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map({'n', 'v'}, ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, {expr = true, desc = 'Jump to next hunk'})

                map({'n', 'v'}, '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, {expr = true, desc = 'Jump to previous hunk'})

                -- Actions
                -- visual mode
                map('v', '<leader>hs', function()
                    gs.stage_hunk {vim.fn.line '.', vim.fn.line 'v'}
                end, {desc = 'stage git hunk'})
                map('v', '<leader>hr', function()
                    gs.reset_hunk {vim.fn.line '.', vim.fn.line 'v'}
                end, {desc = 'reset git hunk'})
                -- normal mode
                map('n', '<leader>hs', gs.stage_hunk, {desc = 'git stage hunk'})
                map('n', '<leader>hr', gs.reset_hunk, {desc = 'git reset hunk'})
                map('n', '<leader>hS', gs.stage_buffer,
                    {desc = 'git Stage buffer'})
                map('n', '<leader>hu', gs.undo_stage_hunk,
                    {desc = 'undo stage hunk'})
                map('n', '<leader>hR', gs.reset_buffer,
                    {desc = 'git Reset buffer'})
                map('n', '<leader>hp', gs.preview_hunk,
                    {desc = 'preview git hunk'})
                map('n', '<leader>hb',
                    function() gs.blame_line {full = false} end,
                    {desc = 'git blame line'})
                map('n', '<leader>hd', gs.diffthis,
                    {desc = 'git diff against index'})
                map('n', '<leader>hD', function() gs.diffthis '~' end,
                    {desc = 'git diff against last commit'})

                -- Toggles
                map('n', '<leader>tb', gs.toggle_current_line_blame,
                    {desc = 'toggle git blame line'})
                map('n', '<leader>td', gs.toggle_deleted,
                    {desc = 'toggle git show deleted'})

                -- Text object
                map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>',
                    {desc = 'select git hunk'})
            end
        }
    }, {
        -- show and navigate open buffers
        'akinsho/bufferline.nvim',
        version = "*",
        lazy = false, -- inexpensive and want bufferline to always show
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function() require("bufferline").setup {} end,
        keys = {
            {"<leader>bb", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous"},
            {"<leader>bc", "<cmd>bd<cr>", desc = "Close"},
            {"<leader>bC", "<cmd>bd!<cr>", desc = "Close (!)"},
            {
                "<leader>bf",
                "<cmd>Telescope buffers previewer=false<cr>",
                desc = "Find"
            }, {"<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Jump"},
            {"<leader>bn", "<cmd>BufferLineCycleNext<cr>", desc = "Next"}, {
                "<leader>bW",
                "<cmd>noautocmd w<cr>",
                desc = "Save without formatting (noautocmd)"
            }, {
                "<leader>be",
                "<cmd>BufferLinePickClose<cr>",
                desc = "Pick which buffer to close"
            },
            {
                "<leader>bh",
                "<cmd>BufferLineCloseLeft<cr>",
                desc = "Close all to the left"
            }, {
                "<leader>bl",
                "<cmd>BufferLineCloseRight<cr>",
                desc = "Close all to the right"
            }, {
                "<leader>bD",
                "<cmd>BufferLineSortByDirectory<cr>",
                desc = "Sort by directory"
            },
            {
                "<leader>bL",
                "<cmd>BufferLineSortByExtension<cr>",
                desc = "Sort by language"
            }
        }
    }, {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                theme = 'catppuccin',
                component_separators = '|',
                section_separators = ''
            }
        }
    }, {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            local function on_attach(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return {
                        desc = "nvim-tree: " .. desc,
                        buffer = bufnr,
                        noremap = true,
                        silent = true,
                        nowait = true
                    }
                end

                api.config.mappings.default_on_attach(bufnr)

                -- on_attach
                vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "v", api.node.open.vertical,
                               opts("Open in vsplit"))
                vim.keymap.set("n", "h", api.node.navigate.parent_close,
                               opts("Close"))
                vim.keymap.set("n", "H", api.tree.collapse_all,
                               opts("Collapse All"))
                vim.keymap.set("n", "C", api.tree.change_root_to_node,
                               opts("CD"))
            end

            require("nvim-tree").setup {on_attach = on_attach}

            vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>",
                           {desc = "Explorer"})
        end
    }, {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- See `:help ibl`
        main = 'ibl',
        opts = {}
    }, 
    {
        -- "gc" to comment visual regions/lines
        'numToStr/Comment.nvim', opts = {}}, 
    {
        -- Fuzzy Finder (files, lsp, etc)
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end
            }
        }
    }, {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {'nvim-treesitter/nvim-treesitter-textobjects'},
        build = ':TSUpdate'
    }, 
    -- kickstart.nvim additional plugins
    require 'user.autoformat', require 'user.debug', --
    -- For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {"nvim-lua/plenary.nvim"},
        -- note `harpoon` declared in init.lua so accessible for key mappings.
        config = function() harpoon = require("harpoon"):setup() end
    }, {
        "catppuccin/nvim",
        name = "catppuccin",
        config = function() vim.cmd.colorscheme 'catppuccin' end
    }

}

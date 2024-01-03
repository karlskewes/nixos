-- [[ Configure plugins ]]
return {
    'tpope/vim-fugitive', {
        -- Detect tabstop and shiftwidth automatically
        'tpope/vim-sleuth'
    }, {
        -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        opts = {}
    }, {
        "folke/trouble.nvim",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        opts = {},
        config = function()
            require("trouble").setup(opts)
            vim.keymap.set("n", "<leader>tt",
                           function() require("trouble").toggle() end,
                           {desc = "[T]rouble Toggle"})
            vim.keymap.set("n", "<leader>tn", function()
                require("trouble").next({skip_groups = true, jump = true})
            end, {desc = "[T]rouble [n]ext"})
            vim.keymap.set("n", "<leader>tp", function()
                require("trouble").previous({skip_groups = true, jump = true})
            end, {desc = "[T]rouble [p]revious"})
            vim.keymap.set("n", "<leader>tw", function()
                require("trouble").toggle("workspace_diagnostics")
            end, {desc = "[T]rouble [W]orkspace Diagnostics"})
            vim.keymap.set("n", "<leader>td", function()
                require("trouble").toggle("document_diagnostics")
            end, {desc = "[T]rouble [D]ocument Diagnostics"})
            vim.keymap.set("n", "<leader>tq", function()
                require("trouble").toggle("quickfix")
            end, {desc = "[T]rouble Quickfix"})
            vim.keymap.set("n", "<leader>tl",
                           function()
                require("trouble").toggle("loclist")
            end, {desc = "[T]rouble Loclist"})
            vim.keymap.set("n", "<leader>tr", function()
                require("trouble").toggle("lsp_references")
            end, {desc = "[T]rouble LSP References"})
        end
    }, {
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
                map('v', '<leader>gs', function()
                    gs.stage_hunk {vim.fn.line '.', vim.fn.line 'v'}
                end, {desc = 'stage git hunk'})
                map('v', '<leader>gr', function()
                    gs.reset_hunk {vim.fn.line '.', vim.fn.line 'v'}
                end, {desc = 'reset git hunk'})
                -- normal mode
                map('n', '<leader>gs', gs.stage_hunk, {desc = 'git stage hunk'})
                map('n', '<leader>gr', gs.reset_hunk, {desc = 'git reset hunk'})
                map('n', '<leader>gS', gs.stage_buffer,
                    {desc = 'git Stage buffer'})
                map('n', '<leader>gu', gs.undo_stage_hunk,
                    {desc = 'undo stage hunk'})
                map('n', '<leader>gR', gs.reset_buffer,
                    {desc = 'git Reset buffer'})
                map('n', '<leader>gp', gs.preview_hunk,
                    {desc = 'preview git hunk'})
                map('n', '<leader>gb',
                    function() gs.blame_line {full = false} end,
                    {desc = 'git blame line'})
                map('n', '<leader>gd', gs.diffthis,
                    {desc = 'git diff against index'})
                map('n', '<leader>gD', function() gs.diffthis '~' end,
                    {desc = 'git diff against last commit'})

                -- Toggles
                map('n', '<leader>gy', gs.toggle_current_line_blame,
                    {desc = 'toggle git blame line'})
                map('n', '<leader>gz', gs.toggle_deleted,
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
        config = function()
            require("bufferline").setup({})
            vim.keymap.set("n", "<leader>bb", "<cmd>BufferLineCyclePrev<cr>",
                           {desc = "Previous"})
            vim.keymap.set("n", "<leader>bc", "<cmd>bd<cr>", {desc = "Close"})
            vim.keymap.set("n", "<leader>bC", "<cmd>bd!<cr>",
                           {desc = "Close (!)"})
            vim.keymap.set("n", "<leader>bf",
                           "<cmd>Telescope buffers previewer=false<cr>",
                           {desc = "Find"})
            vim.keymap.set("n", "<leader>bj", "<cmd>BufferLinePick<cr>",
                           {desc = "Jump"})
            vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>",
                           {desc = "Next"})
            vim.keymap.set("n", "<leader>bW", "<cmd>noautocmd w<cr>",
                           {desc = "Save without formatting (noautocmd)"})
            vim.keymap.set("n", "<leader>be", "<cmd>BufferLinePickClose<cr>",
                           {desc = "Pick which buffer to close"})
            vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>",
                           {desc = "Close all to the left"})
            vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>",
                           {desc = "Close all to the right"})
            vim.keymap.set("n", "<leader>bD",
                           "<cmd>BufferLineSortByDirectory<cr>",
                           {desc = "Sort by directory"})
            vim.keymap.set("n", "<leader>bL",
                           "<cmd>BufferLineSortByExtension<cr>",
                           {desc = "Sort by language"})
        end
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

            require("nvim-tree").setup {
                on_attach = on_attach,
                update_focused_file = {
                    enable = true,
                    debounce_delay = 15,
                    update_root = true,
                    ignore_list = {}
                }
            }

            vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>",
                           {desc = "Explorer"})

            -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#marvinth01
            -- Enabling closing vim even if NvimTree window open.
            vim.api.nvim_create_autocmd("QuitPre", {
                callback = function()
                    local tree_wins = {}
                    local floating_wins = {}
                    local wins = vim.api.nvim_list_wins()
                    for _, w in ipairs(wins) do
                        local bufname = vim.api.nvim_buf_get_name(vim.api
                                                                      .nvim_win_get_buf(
                                                                      w))
                        if bufname:match("NvimTree_") ~= nil then
                            table.insert(tree_wins, w)
                        end
                        if vim.api.nvim_win_get_config(w).relative ~= '' then
                            table.insert(floating_wins, w)
                        end
                    end
                    if 1 == #wins - #floating_wins - #tree_wins then
                        -- Should quit, so we close all invalid windows.
                        for _, w in ipairs(tree_wins) do
                            vim.api.nvim_win_close(w, true)
                        end
                    end
                end
            })

            -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes#go-to-last-used-hidden-buffer-when-deleting-a-buffer
            vim.api.nvim_create_autocmd("BufEnter", {
                nested = true,
                callback = function()
                    local api = require('nvim-tree.api')

                    -- Only 1 window with nvim-tree left: we probably closed a file buffer
                    if #vim.api.nvim_list_wins() == 1 and api.tree.is_tree_buf() then
                        -- Required to let the close event complete. An error is thrown without this.
                        vim.defer_fn(function()
                            -- close nvim-tree: will go to the last hidden buffer used before closing
                            api.tree.toggle({find_file = true, focus = true})
                            -- re-open nivm-tree
                            api.tree.toggle({find_file = true, focus = true})
                            -- nvim-tree is still the active window. Go to the previous window.
                            vim.cmd("wincmd p")
                        end, 0)
                    end
                end
            })
        end
    }, {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- See `:help ibl`
        main = 'ibl',
        opts = {}
    }, {
        -- "gc" to comment visual regions/lines
        'numToStr/Comment.nvim',
        opts = {}
    }, {
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
    }, {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {"nvim-lua/plenary.nvim"},
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            vim.keymap.set("n", "<leader>ha",
                           function() harpoon:list():append() end,
                           {desc = "[H]arpoon [a]dd"})
            vim.keymap.set("n", "<leader>hl", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end, {desc = "[H]arpoon [l]ist"})

            vim.keymap.set("n", "<leader>h1",
                           function() harpoon:list():select(1) end,
                           {desc = "[H]arpoon jump to [1]"})
            vim.keymap.set("n", "<leader>h2",
                           function() harpoon:list():select(3) end,
                           {desc = "[H]arpoon jump to [2]"})
            vim.keymap.set("n", "<leader>h3",
                           function() harpoon:list():select(3) end,
                           {desc = "[H]arpoon jump to [3]"})
            vim.keymap.set("n", "<leader>h4",
                           function() harpoon:list():select(4) end,
                           {desc = "[H]arpoon jump to [4]"})

            vim.keymap.set("n", "<C-,>", function()
                harpoon:list():prev()
            end, {desc = "[H]arpoon [p]revious"})
            vim.keymap.set("n", "<leader>p",
                           function() harpoon:list():prev() end,
                           {desc = "[H]arpoon [p]revious '<C-,>'"})
            vim.keymap.set("n", "<C-.>", function()
                harpoon:list():next()
            end, {desc = "[H]arpoon [n]ext"})
            vim.keymap.set("n", "<leader>n",
                           function() harpoon:list():next() end,
                           {desc = "[H]arpoon [n]ext '<C-.>'"})

        end
    }, {
        "catppuccin/nvim",
        name = "catppuccin",
        config = function() vim.cmd.colorscheme 'catppuccin' end,
        opts = {
            integrations = {
                alpha = true,
                cmp = true,
                dap = true,
                dap_ui = true,
                fidget = true,
                gitsigns = true,
                harpoon = true,
                headlines = true,
                illuminate = true,
                indent_blankline = {enabled = true},
                mason = true,
                markdown = true,
                mini = true,
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = {"undercurl"},
                        hints = {"undercurl"},
                        warnings = {"undercurl"},
                        information = {"undercurl"}
                    }
                },
                telescope = true,
                treesitter = true,
                treesitter_context = true,
                which_key = true
            }
        }
    }, {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "ray-x/guihua.lua", "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter"
        },
        config = function() require("go").setup() end,
        event = {"CmdlineEnter"},
        ft = {"go", 'gomod'},
        build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    }
}

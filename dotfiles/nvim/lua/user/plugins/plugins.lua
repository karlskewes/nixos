-- [[ Configure plugins ]]
return {
    {
        -- :Git commands.
        'tpope/vim-fugitive'
    }, {
        -- Detect tabstop and shiftwidth automatically.
        'tpope/vim-sleuth'
    }, {
        -- Display popup with possible key bindings.
        'folke/which-key.nvim',
        opts = {},
        config = function()
            require('which-key').setup({})

            -- document existing key chains
            require('which-key').register({
                ['<leader>b'] = {name = '[B]uffer', _ = 'which_key_ignore'},
                ['<leader>d'] = {name = '[D]ebug', _ = 'which_key_ignore'},
                ['<leader>g'] = {name = '[G]it', _ = 'which_key_ignore'},
                ['<leader>h'] = {name = '[H]arpoon', _ = 'which_key_ignore'}, -- though bindings not under <leader>h atm.
                ['<leader>l'] = {name = '[L]sp', _ = 'which_key_ignore'},
                ['<leader>p'] = {name = '[P]lugins', _ = 'which_key_ignore'},
                ['<leader>s'] = {name = '[S]earch', _ = 'which_key_ignore'},
                ['<leader>t'] = {name = '[T]rouble', _ = 'which_key_ignore'}
            })

            -- register which-key VISUAL mode
            -- required for visual <leader>gs (hunk stage) to work
            require('which-key').register({
                ['<leader>'] = {name = 'VISUAL <leader>'},
                ['<leader>g'] = {'[G]it Hunk'}
            }, {mode = 'v'})
        end
    }, {
        -- List diagnostics, references, quickfix, etc to solve trouble your code is causing.
        "folke/trouble.nvim",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            require("trouble").setup({})
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
        -- Git decorations, hunk and other utilities.
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
        -- remember last place in file
        "ethanholz/nvim-lastplace",
        event = "BufRead",
        config = function()
            require("nvim-lastplace").setup({
                lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
                lastplace_ignore_filetype = {"gitcommit", "gitrebase"},
                lastplace_open_folds = true
            })
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
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {"nvim-lua/plenary.nvim"},
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup({
                settings = {save_on_toggle = true, sync_on_ui_close = true}
            })

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
                           function() harpoon:list():select(2) end,
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
            vim.keymap.set("n", "<leader>hp",
                           function() harpoon:list():prev() end,
                           {desc = "[H]arpoon [p]revious '<C-,>'"})
            vim.keymap.set("n", "<C-.>", function()
                harpoon:list():next()
            end, {desc = "[H]arpoon [n]ext"})
            vim.keymap.set("n", "<leader>hn",
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
        config = function()
            require("go").setup()

            -- Run gofmt + goimport on save
            local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                    require('go.format').goimport()
                end,
                group = format_sync_grp
            })

            vim.keymap.set("n", "<leader>Ga", "<cmd>GoTestAdd<Cr>",
                           {desc = "[G]o [A]dd Test"})
            vim.keymap.set("n", "<leader>GA", "<cmd>GoTestsAll<Cr>",
                           {desc = "[G]o Add [A]ll Tests"})
            vim.keymap.set("n", "<leader>Ge", "<cmd>GoTestsExp<Cr>",
                           {desc = "[G]o Add [E]xported Tests"})
            vim.keymap.set("n", "<leader>Gi", "<cmd>GoInstallDeps<Cr>",
                           {desc = "[G]o [i]nstall Dependencies"})
            vim.keymap.set("n", "<leader>Gf", "<cmd>GoFillStruct<Cr>",
                           {desc = "[G]o [F]ill Struct"})
            vim.keymap.set("n", "<leader>Gg", "<cmd>GoGenerate<Cr>",
                           {desc = "[G]o [G]enerate"})
            vim.keymap.set("n", "<leader>Gm", "<cmd>GoMod tidy<cr>",
                           {desc = "[G]o [M]od Tidy"})

        end,
        event = {"CmdlineEnter"},
        ft = {"go", 'gomod'},
        build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    }
}

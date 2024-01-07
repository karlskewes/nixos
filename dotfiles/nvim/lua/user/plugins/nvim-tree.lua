return {
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
            vim.keymap
                .set("n", "H", api.tree.collapse_all, opts("Collapse All"))
            vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
        end

        require("nvim-tree").setup({
            on_attach = on_attach,
            update_focused_file = {
                enable = true,
                debounce_delay = 15,
                update_root = true,
                ignore_list = {}
            }
        })

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
}

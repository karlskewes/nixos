-- Shared configuration
-- Language specific configuration lives in ./lua/user/languages/
-- general
lvim.format_on_save.enabled = true
lvim.log.level = "warn"
lvim.colorscheme = "catppuccin" -- alt: "carbonfox" or "onedarker" -- onedark theme broken, missing highlighting
vim.opt.diffopt = "internal,filler,closeoff,iwhite" -- disable vimdiff whitespace showing - can't += here
vim.opt.undofile = false -- disable persistent undo, habitual git + ctrl-u to no-changes
vim.opt.relativenumber = false -- set relative numbered lines
vim.opt.clipboard = "" -- don't default to system clipboard (<C-y|p>)
vim.opt.colorcolumn = "80"
-- vim.opt.foldlevelstart = 99 -- open files with all folds (99!) open
vim.opt.foldmethod = "indent" -- folding, leaves declaration line open
-- vim.opt.foldmethod = "expr" -- folding, set to "expr" for treesitter based folding
-- vim.opt.foldminlines = 1 -- minimum number of lines for a fold to be displayed closed
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- treesitter based folding
-- Disable folding in Telescope's result window.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "TelescopeResults",
    command = [[setlocal nofoldenable]]
})
vim.opt.formatoptions = "qrn1" -- handle formatting nicely
vim.opt.textwidth = 79 -- wrap at this character number on whitespace
vim.opt.wrap = true -- don't display lines as one long line
vim.opt.formatoptions = {
    ["1"] = true,
    ["2"] = true, -- Use indent from 2nd line of a paragraph
    q = true, -- continue comments with gq"
    c = true, -- Auto-wrap comments using textwidth
    r = true, -- Continue comments when pressing Enter
    n = true, -- Recognize numbered lists
    t = false, -- autowrap lines using text width value
    j = true, -- remove a comment leader when joining lines.
    -- Only break if the line was not longer than 'textwidth' when the insert
    -- started and only at a white character that has been entered during the
    -- current insert command.
    l = true,
    v = true
}

-- https://github.com/LunarVim/LunarVim/issues/2986
vim.opt.title = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
lvim.keys.normal_mode["zz"] = 'zA'
lvim.keys.insert_mode["<C-p>"] = '<ESC>p' -- paste from unamed register - <C-V> for pasting from system clipboard
lvim.keys.normal_mode["<C-y>"] = '"+y' -- 10<C-y><CR> - copy 10 lines to system clipboard
lvim.keys.normal_mode["<C-p>"] = '"+p' -- paste from system clipboard
lvim.keys.visual_mode["<C-y>"] = '"+y' -- copy block to system clipboard
lvim.keys.visual_mode["<C-p>"] = '"+p' -- paste block from system clipboard
lvim.keys.insert_mode["<F9>"] = "<ESC>:make<CR>==gi"
lvim.keys.normal_mode["<F9>"] = ":make<CR>=="
-- lvim.keys.normal_mode["<F8>"] = '<CMD>lua require("dapui").toggle()<CR>'

lvim.keys.visual_mode["J"] = ":m '>+1<CR>gv=gv" -- move highlighted block down
lvim.keys.visual_mode["K"] = ":m '<-2<CR>gv=gv" -- move highlighted block up

lvim.keys.normal_mode["<C-d>"] = "<C-d>zz" -- navigate half/whole pages whilst keeping cursor in middle of buffer
lvim.keys.normal_mode["<C-u>"] = "<C-u>zz"
lvim.keys.normal_mode["<C-f>"] = "<C-f>zz"
lvim.keys.normal_mode["<C-b>"] = "<C-b>zz"

lvim.keys.normal_mode["n"] = "nzzzv" -- when searching, keep search term with cursor in the middle of buffer
lvim.keys.normal_mode["N"] = "Nzzzv"

lvim.keys.normal_mode["<C-k>"] = "<cmd>cnext<CR>zz" -- quickfix list navigation
lvim.keys.normal_mode["<C-j>"] = "<cmd>cprev<CR>zz"
lvim.keys.normal_mode["<leader>k"] = "<cmd>lnext<CR>zz"
lvim.keys.normal_mode["<leader>j"] = "<cmd>lprev<CR>zz"

-- User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.lualine.active = true
lvim.builtin.lualine.style = "default"
lvim.builtin.lualine.options.theme = "solarized_dark"
-- broken
-- lvim.builtin.lualine.options.theme = "auto"
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.dap.ui.config.layouts = {
    {
        elements = {
            {id = "scopes", size = 0.40}, {id = "breakpoints", size = 0.20},
            {id = "stacks", size = 0.40} -- {id = "watches", size = 0.25}
        },
        size = 15,
        position = "bottom"
    }
}
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.highlight_git = true
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- set additional linters
local linters = require "lvim.lsp.null-ls.linters"

local harpoon -- enables access by which-key for keymaps.

-- Additional Plugins
lvim.plugins = {
    {"nvim-telescope/telescope-live-grep-args.nvim"}, --
    {"nvim-telescope/telescope-media-files.nvim"}, --
    {"catppuccin/nvim", name = "catppuccin"}, {"EdenEast/nightfox.nvim"},
    {"lunarvim/Onedarker.nvim"}, {'kdheepak/lazygit.nvim'}, {
        "ray-x/lsp_signature.nvim",
        event = "BufRead",
        config = function()
            require"lsp_signature".on_attach({fix_pos = true})
        end
    }, --
    {
        "ethanholz/nvim-lastplace",
        event = "BufRead",
        config = function()
            require("nvim-lastplace").setup({
                lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
                lastplace_ignore_filetype = {
                    "gitcommit", "gitrebase", "svn", "hgcommit"
                },
                lastplace_open_folds = true
            })
        end
    }, --
    {
        "preservim/vim-markdown",
        config = function()
            vim.cmd("let g:vim_markdown_folding_disabled = 1")
        end
    }, {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {"nvim-lua/plenary.nvim"},
        config = function() harpoon = require("harpoon"):setup() end
    }
}

-- Telescope extensions
lvim.builtin.telescope.on_config_done = function(telescope)
    pcall(telescope.load_extension, "live_grep_args")
    pcall(telescope.load_extension, "media_files")
    -- any other extensions loading
end

vim.list_extend(lvim.builtin.telescope.extensions, {
    media_files = {
        -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        filetypes = {"png", "webp", "jpg", "jpeg"},
        find_cmd = "rg"
    }
})

linters.setup {{command = "write-good"}}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- https://github.com/LunarVim/LunarVim/issues/4071#issuecomment-1519978799
-- Persistent Cursor
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end
})

-- Set gohtml files to HTML syntax highlighting
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.gohtml"},
    command = "set filetype=gohtmltmpl"
})

-- Trim all trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {"*"},
    -- @ separater, double back slash for lua escape
    command = ":%s@\\s\\+$@@e"
})

-- load dotfiles configuration with entry here: ~/.config/lvim/lua/user/init.lua
reload("user")

-- Inspiration https://fnune.com/2021/11/20/nuking-most-of-my-vimrc-and-just-using-lunarvim/
function GrepWordUnderCursor()
    local default = vim.api.nvim_eval([[expand("<cword>")]])
    local input = vim.fn.input({prompt = "Search for: ", default = default})
    require("telescope.builtin").grep_string({search = input})
end

lvim.builtin.which_key.mappings["sw"] = {
    "<cmd>lua GrepWordUnderCursor()<CR>", "Text word under cursor"
}

function GrepStringUnderCursor()
    local default = vim.api.nvim_eval([[expand("<cWORD>")]])
    local input = vim.fn.input({prompt = "Search for: ", default = default})
    require("telescope.builtin").grep_string({search = input})
end

lvim.builtin.which_key.mappings["ss"] = {
    "<cmd>lua GrepStringUnderCursor()<CR>", "Text string under cursor"
}

function GrepYankedString()
    ---@diagnostic disable: missing-parameter -- params 2 & 3 are optional
    local default = vim.fn.getreg('"')
    local input = vim.fn.input({prompt = "Search for: ", default = default})
    require("telescope.builtin").grep_string({search = input})
end

lvim.builtin.which_key.mappings["sy"] = {
    "<cmd>lua GrepYankedString()<CR>", "Text yanked"
}

lvim.builtin.which_key.mappings["sz"] = {
    require("telescope").extensions.live_grep_args.live_grep_args,
    "Text with args (-t go, -g /path/to/files)"
    -- "<cmd>lua GrepStringUnderCursor()<CR>", "Text string under cursor"
}

lvim.builtin.which_key.mappings["n"] = {
    name = "Neogen",
    f = {"<cmd>lua require('neogen').generate({ type = 'file' })<CR>", "File"},
    c = {"<cmd>lua require('neogen').generate({ type = 'class' })<CR>", "Class"},
    m = {"<cmd>lua require('neogen').generate({ type = 'func' })<CR>", "Method"},
    t = {"<cmd>lua require('neogen').generate({ type = 'type' })<CR>", "Type"}
}

-- Harpoon keymaps
lvim.builtin.which_key.mappings['h'] = {} -- disable default no highlight search
lvim.builtin.which_key.mappings["h"] = {
    name = "Harpoon",
    a = {function() harpoon:list():append() end, "Append"},
    t = {
        function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        "Toggle Quick Menu"
    },
    -- Toggle previous & next buffers stored within Harpoon list
    j = {function() harpoon:list():prev() end, "Previous"},
    k = {function() harpoon:list():next() end, "Next"},

    -- Quick jump to item in list
    u = {function() harpoon:list():select(1) end, "Jump to 1"},
    i = {function() harpoon:list():select(2) end, "Jump to 2"},
    o = {function() harpoon:list():select(3) end, "Jump to 3"}
}

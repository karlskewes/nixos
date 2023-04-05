-- Shared configuration
-- Language specific configuration lives in ./lua/user/languages/
-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "onedarker" -- alt: "nightfox" -- onedark theme broken, missing highlighting
vim.opt.diffopt = "internal,filler,closeoff,iwhite" -- disable vimdiff whitespace showing - can't += here
vim.opt.undofile = false -- disable persistent undo, habitual git + ctrl-u to no-changes
vim.opt.relativenumber = false -- set relative numbered lines
vim.opt.clipboard = "" -- don't default to system clipboard (<C-y|p>)
vim.opt.colorcolumn = "80"
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
lvim.keys.insert_mode["<C-p>"] = '<ESC>p' -- paste from unamed register - <C-V> for pasting from system clipboard
lvim.keys.normal_mode["<C-y>"] = '"+y' -- 10<C-y><CR> - copy 10 lines to system clipboard
lvim.keys.normal_mode["<C-p>"] = '"+p' -- paste from system clipboard
lvim.keys.visual_mode["<C-y>"] = '"+y' -- copy block to system clipboard
lvim.keys.visual_mode["<C-p>"] = '"+p' -- paste block from system clipboard
lvim.keys.insert_mode["<F9>"] = "<ESC>:make<CR>==gi"
lvim.keys.normal_mode["<F9>"] = ":make<CR>=="
-- lvim.keys.normal_mode["<F8>"] = '<CMD>lua require("dapui").toggle()<CR>'

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
linters.setup {{command = "write-good"}}

-- Additional Plugins
lvim.plugins = {
    {"christianchiarulli/nvcode-color-schemes.vim"}, {"EdenEast/nightfox.nvim"},
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
    } --
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- Trim all trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {"*"},
    -- @ separater, double back slash for lua escape
    command = ":%s@\\s\\+$@@e"
})

-- load dotfiles configuration with entry here: ~/.config/lvim/lua/user/init.lua
require("user")

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
    "<cmd>lua require('telescope.builtin').resume()<CR>", 'resume'
}

lvim.builtin.which_key.mappings["n"] = {
    name = "Neogen",
    f = {"<cmd>lua require('neogen').generate({ type = 'file' })<CR>", "File"},
    c = {"<cmd>lua require('neogen').generate({ type = 'class' })<CR>", "Class"},
    m = {"<cmd>lua require('neogen').generate({ type = 'func' })<CR>", "Method"},
    t = {"<cmd>lua require('neogen').generate({ type = 'type' })<CR>", "Type"}
}

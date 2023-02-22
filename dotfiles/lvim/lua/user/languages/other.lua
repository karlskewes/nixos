-- :MasonInstall shfmt
--
lvim.builtin.dap.active = true
lvim.builtin.treesitter.ensure_installed = {
    "bash", "c", "dockerfile", "go", "gomod", "gowork", "hcl", "html",
    "javascript", "json", "kotlin", "lua", "make", "markdown", "nix", "proto",
    "python", "typescript", "toml", "tsx", "css", "rust", "java", "yaml"
}
lvim.builtin.treesitter.ignore_install = {"haskell"}
lvim.builtin.treesitter.highlight.enabled = true

vim.list_extend(lvim.plugins, {
    {'google/vim-jsonnet'}, --
    {'aliou/bats.vim'}, --
    {
        'z0mbix/vim-shfmt',
        config = function() vim.cmd("let g:shfmt_fmt_on_save = 1") end
    }, --
    {
        'hashivim/vim-terraform',
        config = function()
            vim.cmd("let g:terraform_fmt_on_save=1")
            -- "Allow vim-terraform to automatically fold (hide until unfolded) sections of terraform code.
            -- vim.cmd("let g:terraform_fold_sections=0")
        end
    }, --
    {
        "danymat/neogen", -- generate docstrings automatically.
        config = function() require("neogen").setup {} end
    } --
})

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {command = "prettier", filetypes = {"markdown"}},
    {command = "nixfmt", filetypes = {"nix"}}
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- TODO: PR this change to vim-shfmt
vim.api.nvim_create_autocmd("BufWritePre",
                            {pattern = {"*.bats"}, command = "shfmt -ln bats"})

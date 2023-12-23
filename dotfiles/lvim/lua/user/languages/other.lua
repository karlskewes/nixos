-- :MasonInstall bash-debug-adapter bash-language-server dockerfile-language-server
-- :MasonInstall htmx-lsp json-lsp jsonlint lua-language-server protolint rnix-lsp
-- :MasonInstall shellcheck shfmt yaml-language-server
--
lvim.builtin.dap.active = true
lvim.builtin.treesitter.ensure_installed = {
    "bash", "c", "dockerfile", "gitignore", "git_rebase", "hcl", "json",
    "jsonnet", "ini", "kotlin", "lua", "make", "markdown", "markdown_inline",
    "nix", "proto", "python", "sql", "terraform", "toml", "rust", "java", "yaml"
}
lvim.builtin.treesitter.ignore_install = {"haskell"}
lvim.builtin.treesitter.highlight.enabled = true

-- azure_pipelines_ls has precedence but is not needed.
-- ~/.local/share/lunarvim/site/after/ftplugin/yaml.lua
lvim.lsp.automatic_configuration.skipped_servers =
    vim.tbl_filter(function(server)
        return server ~= "azure_pipelines_language_server"
    end, lvim.lsp.automatic_configuration.skipped_servers)

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {command = "prettier", filetypes = {"markdown"}},
    {command = "nixfmt", filetypes = {"nix"}},
    {command = "shfmt", filetypes = {"sh"}},
    {command = "shfmt", args = {"-ln", "bats"}, filetypes = {"bats"}}
}

vim.filetype.add {extension = {bats = "bats"}}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {{command = "protolint", filetypes = {"proto"}}}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)

vim.list_extend(lvim.plugins, {
    {'google/vim-jsonnet'}, --
    {'aliou/bats.vim'}, --
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

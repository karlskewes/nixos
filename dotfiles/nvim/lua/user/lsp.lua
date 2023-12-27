-- :MasonInstall delve gopls golangci-lint-langserver goimports gofumpt gomodifytags gotests impl staticcheck
return {
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
        -- Signature hints
        "ray-x/lsp_signature.nvim",
        event = "BufRead",
        config = function()
            require"lsp_signature".on_attach({fix_pos = true})
        end
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
    }
}

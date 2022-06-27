-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "onedarker"
vim.opt.diffopt = "internal,filler,closeoff,iwhite" -- disable vimdiff whitespace showing - can't += here
vim.opt.undofile = false -- disable persistent undo, habitual git + ctrl-u to no-changes
vim.opt.relativenumber = false -- set relative numbered lines
vim.opt.clipboard = "" -- don't default to system clipboard (<C-y|p>)
vim.opt.colorcolumn = "80"
vim.opt.formatoptions = "qrn1" -- handle formatting nicely
vim.opt.textwidth = 79 -- wrap at this character number on whitespace
vim.opt.wrap = true -- don't display lines as one long line

-- Inspiration https://fnune.com/2021/11/20/nuking-most-of-my-vimrc-and-just-using-lunarvim/
function GrepWordUnderCursor()
  local default = vim.api.nvim_eval([[expand("<cword>")]])
  local input = vim.fn.input({ prompt = "Search for: ", default = default })
  require("telescope.builtin").grep_string({ search = input })
end

lvim.builtin.which_key.mappings["sw"] = {
  "<cmd>lua GrepWordUnderCursor()<CR>", "Text word under cursor"
}

function GrepStringUnderCursor()
  local default = vim.api.nvim_eval([[expand("<cWORD>")]])
  local input = vim.fn.input({ prompt = "Search for: ", default = default })
  require("telescope.builtin").grep_string({ search = input })
end

lvim.builtin.which_key.mappings["ss"] = {
  "<cmd>lua GrepStringUnderCursor()<CR>", "Text string under cursor"
}

function GrepYankedString()
  local default = vim.fn.getreg('"')
  local input = vim.fn.input({ prompt = "Search for: ", default = default })
  require("telescope.builtin").grep_string({ search = input })
end

lvim.builtin.which_key.mappings["sy"] = {
  "<cmd>lua GrepYankedString()<CR>", "Text yanked"
}

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
lvim.keys.insert_mode["<C-p>"] = '<ESC>p' -- paste from unamed register - <C-V> for pasting from system clipboard
lvim.keys.normal_mode["<C-y>"] = '"+y' -- 10<C-y><CR> - copy 10 lines to system clipboard
lvim.keys.normal_mode["<C-p>"] = '"+p' -- paste from system clipboard
lvim.keys.visual_mode["<C-y>"] = '"+y' -- copy block to system clipboard
lvim.keys.visual_mode["<C-p>"] = '"+p' -- paste block from system clipboard
lvim.keys.insert_mode["<F9>"] = "<ESC>:make<CR>==gi"
lvim.keys.normal_mode["<F9>"] = ":make<CR>=="
lvim.keys.normal_mode["<F8>"] = '<CMD>lua require("dapui").toggle()<CR>'

-- User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.lualine.active = true
lvim.builtin.lualine.style = "default"
lvim.builtin.lualine.options.theme = "solarized_dark"
-- broken
-- lvim.builtin.lualine.options.theme = "auto"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.dap.active = true
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.highlight_git = true
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

lvim.builtin.treesitter.ensure_installed = {
  "bash", "c", "dockerfile", "go", "gomod", "gowork", "hcl", "html",
  "javascript", "json", "kotlin", "lua", "make", "markdown", "nix", "proto",
  "python", "typescript", "toml", "tsx", "css", "rust", "java", "yaml"
}
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- additional key mappings on leader
lvim.builtin.which_key.mappings["t"] = {
  name = "Test",
  f = { "<cmd>Ultest<cr>", "File" },
  n = { "<cmd>UltestNearest<cr>", "Nearest" },
  s = { "<cmd>UltestSummary<cr>", "Summary" }
}

-- fix Lua with manual installation
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers,
  { "sumneko_lua" })
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

-- require("lspconfig")["sumneko_lua"].setup({
require("lvim.lsp.manager").setup("sumneko_lua", {
  cmd = {
    -- TODO: support home-manager only lua-language server under /home/..
    "/etc/profiles/per-user/karl/bin/lua-language-server", "-E",
    "/etc/profiles/per-user/karl/share/lua-language-server/main.lua"
  },
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' }
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true)
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = { enable = false }
    }
  }
})

-- set a formatter if you want to override the default lsp one (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
  { command = "goimports", filetypes = { "go" } }, -- be nice if this was in gopls
  { command = "lua-format", filetypes = { "lua" } },
  { command = "prettier", filetypes = { "markdown" } },
  { command = "nixfmt", filetypes = { "nix" } }
}

-- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "flake8", filetypes = { "python" } },
  { command = "pylint", filetypes = { "python" } }, --
  { command = "write-good" }
}

-- Additional Plugins
lvim.plugins = {
  { 'aliou/bats.vim' }, { 'kdheepak/lazygit.nvim' },
  { 'leoluz/nvim-dap-go', config = function() require "dap-go".setup() end },
  { 'mfussenegger/nvim-dap-python' }, { 'google/vim-jsonnet' }, {
    "ray-x/lsp_signature.nvim",
    config = function()
      require "lsp_signature".on_attach({ fix_pos = true })
    end,
    event = "BufRead"
  }, {
    "ethanholz/nvim-lastplace",
    event = "BufRead",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = {
          "gitcommit", "gitrebase", "svn", "hgcommit"
        },
        lastplace_open_folds = true
      })
    end
  }, {
    'z0mbix/vim-shfmt',
    config = function() vim.cmd("let g:shfmt_fmt_on_save = 1") end
  }, {
    'hashivim/vim-terraform',
    config = function()
      vim.cmd("let g:terraform_fmt_on_save=1")
      -- "Allow vim-terraform to automatically fold (hide until unfolded) sections of terraform code.
      -- vim.cmd("let g:terraform_fold_sections=0")
    end
  }, {
    "rcarriga/nvim-dap-ui",
    config = function()
      require "dapui".setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.40 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks", size = 0.40 }
              -- {id = "watches", size = 0.25}
            },
            size = 15,
            position = "bottom"
          }
        }
      })
    end
  }, {
    "nvim-neotest/neotest"
    -- FIXME: convert to https://github.com/nvim-neotest/neotest
    --[[
        "rcarriga/vim-ultest",
        cmd = {"Ultest", "UltestSummary", "UltestNearest"},
        wants = "vim-test",
        requires = {"vim-test/vim-test"},
        run = ":UpdateRemotePlugins",
        opt = true,
        event = {"BufEnter *_test.*,*_spec.*"}
    }
  ]] --
  }
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- Trim all trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*" },
  -- @ separater, double back slash for lua escape
  command = ":%s@\\s\\+$@@e"
})

-- TODO: PR this change to vim-shfmt
vim.api.nvim_create_autocmd("BufWritePre",
  { pattern = { "*.bats" }, command = "shfmt -ln bats" })

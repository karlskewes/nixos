-- TODO: Build for nix
-- require('everforest').setup({
--   -- background = 'hard',
--   transparent_background_level = 0,
-- })
-- vim.cmd.colorscheme('everforest')
-- vim.cmd('highlight Normal guibg=black')

require('catppuccin').setup({
  default_integrations = false,
  integrations = {
    blink_cmp = true,
    dap = true,
    dap_ui = true,
    fidget = true,
    indent_blankline = {
      enabled = true,
      scope_color = 'lavender', -- catppuccin color (eg. `lavender`) Default: text
      colored_indent_levels = false,
    },
    lsp_trouble = true,
    markdown = true,
    mini = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { 'italic' },
        hints = { 'italic' },
        warnings = { 'italic' },
        information = { 'italic' },
        ok = { 'italic' },
      },
      underlines = {
        errors = { 'underline' },
        hints = { 'underline' },
        warnings = { 'underline' },
        information = { 'underline' },
        ok = { 'underline' },
      },
      inlay_hints = {
        background = true,
      },
    },
    telescope = true,
    treesitter = true,
    treesitter_context = true,
    which_key = true,
  },
  color_overrides = {
    mocha = {},
  },
})

require('lackluster').setup({
  tweak_pallet = {
    -- ('default' is default) ('#ffaaff' is a custom colorcode)
    lack = 'default',
    luster = 'default',
    orange = 'default',
    yellow = 'default',
    green = 'default',
    blue = 'default',
    red = 'default',
    black = 'default',
    gray1 = 'default',
    gray2 = 'default',
    gray3 = 'default',
    gray4 = 'default',
    gray5 = 'default',
    gray6 = 'default',
    gray7 = 'default',
    gray8 = 'default',
    gray9 = 'default',
  },
})

vim.cmd.colorscheme('catppuccin')
-- vim.cmd.colorscheme('everforest') -- :hi Normal guibg=#1a1a1a
-- vim.cmd.colorscheme('lackluster-mint')

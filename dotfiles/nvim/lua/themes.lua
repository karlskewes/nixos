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

-- Set DAP Breakpoint sign and other marker details.
-- https://github.com/mfussenegger/nvim-dap/discussions/355#discussioncomment-4398846
vim.fn.sign_define(
  'DapBreakpoint',
  { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' }
)
vim.fn.sign_define(
  'DapBreakpointCondition',
  { text = 'ﳁ', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' }
)
vim.fn.sign_define(
  'DapBreakpointRejected',
  { text = '', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' }
)
vim.fn.sign_define(
  'DapLogPoint',
  { text = '', texthl = 'DapLogPoint', linehl = 'DapLogPoint', numhl = 'DapLogPoint' }
)
vim.fn.sign_define(
  'DapStopped',
  { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' }
)

vim.cmd.colorscheme('catppuccin')

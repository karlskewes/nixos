-- Add indentation guides even on blank lines
require('ibl').setup()

--  'mfussenegger/nvim-lint',
-- require('lint').linters_by_ft = { markdown = { 'vale' } }
-- vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
--   callback = function()
--     require('lint').try_lint()
--   end,
-- })

-- Autoformat
-- `:checkhealth conform` to see what formatters are installed or missing.
local conform_opts = {
  notify_on_error = false,
  format_on_save = function(bufnr)
    if vim.g.format_on_save_enabled then
      return
    end
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    local disable_filetypes = { c = true, cpp = true, go = true }
    local lsp_format_opt
    if disable_filetypes[vim.bo[bufnr].filetype] then
      lsp_format_opt = 'never'
    else
      lsp_format_opt = 'fallback'
    end
    return {
      timeout_ms = 500,
      lsp_fallback = lsp_format_opt,
    }
  end,
  formatters_by_ft = {
    go = { 'goimports', 'gofumpt', 'gofmt' },
    hcl = { 'terraform_fmt' },
    javascript = { 'eslint_d', 'prettier', stop_after_first = true },
    json = { 'prettier', stop_after_first = true },
    jsonnet = { 'jsonnetfmt' },
    lua = { 'stylua' },
    markdown = { 'prettier', stop_after_first = true },
    nix = { 'nixfmt' },
    -- proto = { 'buf' }, -- TODO: toggle disable.
    python = { 'isort', 'black' },
    rust = { 'rustfmt' },
    sh = { 'shfmt' },
    sql = { 'sql_formatter' },
    templ = { 'templ' },
    toml = { 'tombi' },
    terraform = { 'terraform_fmt' },
    yaml = { 'prettier', stop_after_first = true },
    zig = { 'zigfmt' },
  },
}

require('conform').setup(conform_opts)

vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
  local enabled = vim.g.format_on_save_enabled
  vim.g.format_on_save_enabled = not enabled
  print('Format on save enabled:', not vim.g.format_on_save_enabled)
end, { desc = '[F]ormat On Save Toggle' })

-- https://github.com/3rd/image.nvim
require('image').setup({
  backend = 'kitty',
  processor = 'magick_cli', -- 'magick_rock' may be faster?
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      floating_windows = true, -- if true, images will be rendered in floating markdown windows
      filetypes = { 'markdown', 'vimwiki' }, -- markdown extensions (ie. quarto) can go here
    },
    neorg = {
      enabled = false,
      filetypes = { 'norg' },
    },
    typst = {
      enabled = false,
      filetypes = { 'typst' },
    },
    html = {
      enabled = false,
    },
    css = {
      enabled = false,
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = nil,
  max_height_window_percentage = 50,
  window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
  window_overlap_clear_ft_ignore = {
    'cmp_menu',
    'cmp_docs',
    'snacks_notif',
    'scrollview',
    'scrollview_sign',
  },
  editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
  tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
  hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' }, -- render image files as images when opened
})

-- File explorer, edit like a Neovim buffer
require('oil').setup({
  keymaps = { ['<M-h>'] = 'actions.select_split' },
  view_options = { show_hidden = true },
})
-- Open parent directory in current window
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
-- Open parent directory in floating window
vim.keymap.set('n', '<leader>-', require('oil').toggle_float, { desc = 'Oil' })

-- List diagnostics, references, quickfix, to solve trouble your code is causing.
vim.keymap.set(
  'n',
  '<leader>tt',
  '<cmd>Trouble diagnostics toggle<cr>',
  { desc = '[T]rouble Toggle' }
)
vim.keymap.set(
  'n',
  '<leader>tb',
  '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
  { desc = '[T]rouble [B]uffer Diagnostics' }
)
vim.keymap.set(
  'n',
  '<leader>ts',
  '<cmd>Trouble symbols toggle focus=false<cr>',
  { desc = '[Trouble] [S]ymbols' }
)
vim.keymap.set(
  'n',
  '<leader>tr',
  '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
  { desc = '[T]rouble LSP [R]eferences' }
)
vim.keymap.set(
  'n',
  '<leader>tl',
  '<cmd>Trouble loclist toggle<cr>',
  { desc = '[T]rouble [L]oclist' }
)
vim.keymap.set(
  'n',
  '<leader>tq',
  '<cmd>Trouble qflist toggle<cr>',
  { desc = '[T]rouble [Q]uickfix' }
)
vim.keymap.set('n', '<leader>tn', function()
  if require('trouble').is_open() then
    require('trouble').next({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = '[T]rouble [n]ext' })
vim.keymap.set('n', '<leader>tp', function()
  if require('trouble').is_open() then
    require('trouble').prev({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = '[T]rouble [p]revious' })
require('trouble').setup()

-- Display popup with possible key bindings.
require('which-key').setup({})
local wk = require('which-key')
wk.add({
  -- document existing key chains
  { '<leader>b', group = '[B]uffer' },
  { '<leader>b_', hidden = true },
  { '<leader>d', group = '[D]ebug' },
  { '<leader>d_', hidden = true },
  { '<leader>g', group = '[G]it' },
  { '<leader>g_', hidden = true },
  { '<leader>l', group = '[L]sp' },
  { '<leader>l_', hidden = true },
  { '<leader>p', group = '[P]lugins' },
  { '<leader>p_', hidden = true },
  { '<leader>s', group = '[S]earch' },
  { '<leader>s_', hidden = true },
  { '<leader>t', group = '[T]rouble' },
  { '<leader>t_', hidden = true },
  { '<leader>v', group = '[V]isits' },
  { '<leader>v_', hidden = true },
})

-- Set lualine as statusline
-- See `:help lualine.txt`
local lualine_opts = {
  options = {
    theme = 'catppuccin',
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = {},
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

require('lualine').setup(lualine_opts)

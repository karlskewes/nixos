local dap = require('dap')
local dapui = require('dapui')
require('nvim-dap-virtual-text').setup({})

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
dapui.setup({
  layouts = {
    -- {
    -- elements = {
    -- { id = 'scopes', size = 0.25 },
    -- { id = 'watches', size = 0.25 },
    -- { id = 'breakpoints', size = 0.25 },
    -- { id = 'stacks', size = 0.25 },
    --   },
    --   position = 'left',
    --   size = 0.28,
    -- },
    {
      elements = {
        -- breakpoints and repl which includes controls and stdout logs.
        -- local vars handled by nvim-dap-virtual-text.
        { id = 'breakpoints', size = 0.30 },
        { id = 'repl', size = 0.70 },
        -- { id = 'console', size = 0.5 },
      },
      position = 'bottom',
      size = 0.3,
    },
  },
})

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Install golang specific config
require('dap-go').setup({})

-- TODO
-- -- Install python specific config
-- local mason_path = vim.fn.glob(vim.fn.stdpath('data') .. '/mason/')
-- pcall(function()
--   require('dap-python').setup(mason_path .. 'packages/debugpy/venv/bin/python')
-- end)
-- -- Default of unittest can struggle to find modules but pytest seems reliable.
-- pcall(function()
--   require('dap-python').test_runner = 'pytest'
-- end)

vim.keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = '[B]reakpoint condition' })
vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint, { desc = '[T]oggle Breakpoint' })
vim.keymap.set('n', '<leader>db', dap.step_back, { desc = 'Step [b]ack' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[C]ontinue' })
vim.keymap.set('n', '<leader>dC', dap.run_to_cursor, { desc = 'Run to [C]ursor' })
vim.keymap.set('n', '<leader>dd', dap.disconnect, { desc = '[D]isconnect' })
vim.keymap.set('n', '<leader>de', function()
  require('dapui').eval(nil, { enter = true })
end, { desc = 'Eval var' })
vim.keymap.set('n', '<leader>dg', dap.session, { desc = '[G]et session' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step [i]nto' })
vim.keymap.set('n', '<leader>dl', '<CMD>DapShowLog<CR>', { desc = 'Show [l]og' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Step [o]ver' })
vim.keymap.set('n', '<leader>du', dap.step_out, { desc = 'Step o[u]t' })
vim.keymap.set('n', '<leader>dp', dap.pause, { desc = '[P]ause' })
vim.keymap.set('n', '<leader>dr', dap.repl.toggle, { desc = 'Toggle [r]epl' })
vim.keymap.set('n', '<leader>ds', dap.continue, { desc = '[S]tart' })
vim.keymap.set('n', '<leader>dT', dap.terminate, { desc = '[T]erminate' })
vim.keymap.set('n', '<leader>dq', dap.close, { desc = '[Q]uit' })
vim.keymap.set('n', '<leader>dz', dapui.toggle, { desc = 'Toggle UI' })

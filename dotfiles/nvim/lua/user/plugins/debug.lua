return {
  'rcarriga/nvim-dap-ui',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
    'theHamsta/nvim-dap-virtual-text',
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    require('nvim-dap-virtual-text').setup()
    require('mason-nvim-dap').setup({
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,
      -- see mason-nvim-dap README for more information
      handlers = {},
      ensure_installed = { 'delve' },
    })

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
    vim.keymap.set('n', '<leader>dl', '<CMD>DapShowLog<CR', { desc = 'Show [l]og' })
    vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Step [o]ver' })
    vim.keymap.set('n', '<leader>du', dap.step_out, { desc = 'Step o[u]t' })
    vim.keymap.set('n', '<leader>dp', dap.pause, { desc = '[P]ause' })
    vim.keymap.set('n', '<leader>dr', dap.repl.toggle, { desc = 'Toggle [r]epl' })
    vim.keymap.set('n', '<leader>ds', dap.continue, { desc = '[S]tart' })
    vim.keymap.set('n', '<leader>dq', dap.close, { desc = '[Q]uit' })
    vim.keymap.set('n', '<leader>dz', dapui.toggle, { desc = 'Toggle UI' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup({
      -- Set icons to characters that are more likely to work in every terminal.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      layouts = {
        -- top because stacking two on bottom produces unexpected results.
        -- { elements = { 'console' }, size = 10, position = 'top' }, --
        -- bottom
        -- {
        --   elements = {
        --     { id = 'scopes', size = 0.40 },
        --     { id = 'breakpoints', size = 0.20 },
        --     { id = 'stacks', size = 0.40 },
        --     -- { id = "watches", size = 0.25 }
        --   },
        --   size = 15,
        --   position = 'bottom',
        -- },
        {
          elements = { 'stacks' },
          size = 15,
          position = 'bottom',
        },
      },
    })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()

    -- Install python specific config
    local mason_path = vim.fn.glob(vim.fn.stdpath('data') .. '/mason/')
    pcall(function()
      require('dap-python').setup(mason_path .. 'packages/debugpy/venv/bin/python')
    end)
    -- Default of unittest can struggle to find modules but pytest seems reliable.
    pcall(function()
      require('dap-python').test_runner = 'pytest'
    end)
  end,
}

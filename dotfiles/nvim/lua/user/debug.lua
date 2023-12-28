-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)
return {
    -- NOTE: Yes, you can install new plugins here!
    'mfussenegger/nvim-dap',
    -- NOTE: And you can specify dependencies as well
    dependencies = {
        -- Creates a beautiful debugger UI
        'rcarriga/nvim-dap-ui', -- Installs the debug adapters for you
        'williamboman/mason.nvim', 'jay-babu/mason-nvim-dap.nvim',

        -- Add your own debuggers here
        'leoluz/nvim-dap-go', "mfussenegger/nvim-dap-python"
    },
    config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'

        require('mason-nvim-dap').setup {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_setup = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                -- Update this to ensure that you have the debuggers for the langs you want
                'delve'
            }
        }

        -- Basic debugging keymaps, feel free to change to your liking!
        vim.keymap.set('n', '<F5>', dap.continue,
                       {desc = 'Debug: Start/Continue'})
        vim.keymap.set('n', '<F1>', dap.step_into, {desc = 'Debug: Step Into'})
        vim.keymap.set('n', '<F2>', dap.step_over, {desc = 'Debug: Step Over'})
        vim.keymap.set('n', '<F3>', dap.step_out, {desc = 'Debug: Step Out'})
        vim.keymap.set('n', '<leader>dB', function()
            dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end, {desc = 'Breakpoint condition'})
        vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint,
                       {desc = "Toggle Breakpoint"})
        vim.keymap.set('n', '<leader>db', dap.step_back, {desc = "Step Back"})
        vim.keymap.set('n', '<leader>dc', dap.continue, {desc = "Continue"})
        vim.keymap.set('n', '<leader>dC', dap.run_to_cursor,
                       {desc = "Run To Cursor"})
        vim.keymap.set('n', '<leader>dd', dap.disconnect, {desc = "Disconnect"})
        vim.keymap.set('n', '<leader>dg', dap.session, {desc = "Get Session"})
        vim.keymap.set('n', '<leader>di', dap.step_into, {desc = "Step Into"})
        vim.keymap.set('n', '<leader>do', dap.step_over, {desc = "Step Over"})
        vim.keymap.set('n', '<leader>du', dap.step_out, {desc = "Step Out"})
        vim.keymap.set('n', '<leader>dp', dap.pause, {desc = "Pause"})
        vim.keymap.set('n', '<leader>dr', dap.repl.toggle,
                       {desc = "Toggle Repl"})
        vim.keymap.set('n', '<leader>ds', dap.continue, {desc = "Start"})
        vim.keymap.set('n', '<leader>dq', dap.close, {desc = "Quit"})

        -- Dap UI setup
        -- For more information, see |:help nvim-dap-ui|
        dapui.setup {
            -- Set icons to characters that are more likely to work in every terminal.
            --    Feel free to remove or use ones that you like more! :)
            --    Don't feel like these are good choices.
            icons = {expanded = '▾', collapsed = '▸', current_frame = '*'},
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
                    disconnect = '⏏'
                }
            },
            layouts = {
                -- top because stacking two on bottom produces unexpected results.
                {elements = {"console"}, size = 10, position = "top"}, --
                -- bottom
                {
                    elements = {
                        {id = "scopes", size = 0.40},
                        {id = "breakpoints", size = 0.20},
                        {id = "stacks", size = 0.40} -- {id = "watches", size = 0.25}
                    },
                    size = 15,
                    position = "bottom"
                }
            }
        }

        -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
        vim.keymap.set('n', '<F7>', dapui.toggle, {desc = 'Toggle UI'})
        -- errors, unsure why. FIXME
        -- vim.keymap.set('n', '<leader>dU', dapui.toggle({reset = true}),
        --                {desc = "Toggle UI"})

        dap.listeners.after.event_initialized['dapui_config'] = dapui.open
        dap.listeners.before.event_terminated['dapui_config'] = dapui.close
        dap.listeners.before.event_exited['dapui_config'] = dapui.close

        -- Install golang specific config
        require('dap-go').setup()

        -- Install python specific config
        local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
        pcall(function()
            require("dap-python").setup(mason_path ..
                                            "packages/debugpy/venv/bin/python")
        end)
        -- Default of unittest can struggle to find modules but pytest seems reliable.
        pcall(function() require("dap-python").test_runner = "pytest" end)
    end
}
---@type vim.lsp.Config
local config = {
  ['rust-analyzer'] = {
    -- $ rust-analyzer --print-config-schema
    imports = {
      granularity = {
        group = 'module',
      },
      prefix = 'self',
    },
    cargo = {
      features = 'all',
    },
    check = {
      features = 'all',
      command = 'clippy',
      extraArgs = {
        '--',
        '--no-deps',
        -- https://doc.rust-lang.org/stable/clippy/index.html
        '-Dclippy::complexity',
        '-Dclippy::correctness',
        '-Wclippy::all',
        '-Wclippy::cargo',
        '-Wclippy::pedantic',
        '-Wclippy::nursery',
      },
    },
    procMacro = {
      enable = true,
    },
  },
}

return config

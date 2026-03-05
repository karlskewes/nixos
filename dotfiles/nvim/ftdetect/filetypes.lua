-- Comprehensive filetype detection for custom and compound filetypes
vim.filetype.add({
  extension = {
    -- Go-related
    templ = 'templ',

    -- Jinja2 templates
    j2 = 'jinja',

    -- Use standard neovim filetypes instead of custom ones
    jsx = 'javascriptreact', -- instead of 'javascript.jsx'
    tsx = 'typescriptreact', -- instead of 'typescript.tsx'

    -- OpenTofu/Terraform (use terraform filetype)
    tf = 'terraform',
    tfvars = 'terraform-vars',
  },

  filename = {
    -- Go workspace
    ['go.work'] = 'gomod', -- Use gomod filetype for go.work files
    ['go.sum'] = 'gosum',

    -- Docker compose (use yaml)
    ['docker-compose.yml'] = 'yaml',
    ['docker-compose.yaml'] = 'yaml',
    ['compose.yml'] = 'yaml',
    ['compose.yaml'] = 'yaml',

    -- GitLab CI (use yaml)
    ['.gitlab-ci.yml'] = 'yaml',
    ['.gitlab-ci.yaml'] = 'yaml',
  },

  pattern = {
    -- Go templates
    ['.*%.tmpl'] = 'gotmpl',
    ['.*%.gotmpl'] = 'gotmpl',

    -- Helm values files (use yaml)
    ['.*values.*%.ya?ml'] = 'yaml',
    ['Chart%.ya?ml'] = 'yaml',

    -- GitLab CI files
    ['%.gitlab/.*%.ya?ml'] = 'yaml',
  },
})

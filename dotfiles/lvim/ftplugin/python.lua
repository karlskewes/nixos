lvim.builtin.which_key.mappings["dm"] = {
    "<cmd>lua require('dap-python').test_method()<cr>", "Test Method"
}
lvim.builtin.which_key.mappings["df"] = {
    "<cmd>lua require('dap-python').test_class()<cr>", "Test Class"
}
lvim.builtin.which_key.vmappings["d"] = {
    name = "Debug",
    s = {
        "<cmd>lua require('dap-python').debug_selection()<cr>",
        "Debug Selection"
    }
}

lvim.builtin.which_key.mappings["P"] = {
    name = "Python",
    r = {"<cmd>pip -r requirements.txt<Cr>", "Install pip requirements"}
}

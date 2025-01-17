return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    -- event = "InsertEnter",
    dependencies = { { "zbirenbaum/copilot-cmp", opts = {} } },
    opts = {
        panel = { enabled = false },
        suggestion = { enabled = false },
        filetypes = {
            yaml = true,
            toml = true,
            markdown = true,
            gitcommit = true,
            gitrebase = true,
        },
    },
}

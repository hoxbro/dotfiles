return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        -- event = "InsertEnter",
        dependencies = { "fang2hou/blink-copilot" },
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
    },
    {
        "saghen/blink.cmp",
        opts = {
            sources = {
                default = { "copilot" },
                providers = {
                    copilot = { name = "copilot", module = "blink-copilot", score_offset = 100, async = true },
                },
            },
        },
    },
}

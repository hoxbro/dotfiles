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
        config = function(_, opts)
            require("copilot").setup(opts)
            require("sidekick").setup()
        end,
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
    {
        "folke/sidekick.nvim",
        lazy = true,
        dependencies = { "zbirenbaum/copilot.lua" },
        config = function()
            vim.keymap.set("n", "<Tab>", function()
                if not require("sidekick").nes_jump_or_apply() then return "<Tab>" end
            end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })
        end,
    },
}

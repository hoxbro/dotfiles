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
    {
        "folke/sidekick.nvim",
        lazy = true,
        dependencies = { "zbirenbaum/copilot.lua" },
        opts = {
            cli = {
                mux = { backend = "tmux", enabled = true },
                win = {
                    keys = { nav_left = { "<Esc>", "nav_left", expr = true, desc = "navigate to the left window" } },
                },
            },
        },
        keys = {
            {
                "<leader>ai",
                function() print("    🤖") end,
                desc = "Start AI",
            },
            {
                "<leader>aa",
                function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>ad",
                function() require("sidekick.cli").close() end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>at",
                function() require("sidekick.cli").send({ name = "claude", msg = "{this}" }) end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>af",
                function() require("sidekick.cli").send({ name = "claude", msg = "{file}" }) end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function() require("sidekick.cli").send({ name = "claude", msg = "{selection}" }) end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function() require("sidekick.cli").prompt({ name = "claude" }) end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
            {
                "<leader>aq",
                function() require("sidekick.nes").disable() end,
                mode = "n",
                desc = "Sidekick Quit NES",
            },
        },
        config = function(_, opts)
            local sidekick = require("sidekick")
            sidekick.setup(opts)

            -- Setting to not start AI on when pressing tab
            vim.keymap.set("n", "<Tab>", function()
                if not sidekick.nes_jump_or_apply() then return "<Tab>" end
            end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })
        end,
    },
}

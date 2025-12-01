local ai = function()
    require("copilot")
    local sk = require("sidekick")
    vim.keymap.set("n", "<Tab>", function()
        if not sk.nes_jump_or_apply() then return "<Tab>" end
    end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })
    print("Started AI")
end

vim.api.nvim_create_user_command("AI", ai, { desc = "Start AI" })
vim.keymap.set("n", "<leader>ai", ai, { desc = "Start AI" })

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
    },
}

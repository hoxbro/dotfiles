return {
    {
        "aaronik/treewalker.nvim",
        keys = {
            { "gk", function() require("treewalker").move_up() end, mode = { "n", "v" }, desc = "Move up" },
            { "gj", function() require("treewalker").move_down() end, mode = { "n", "v" }, desc = "Move down" },
            { "gh", function() require("treewalker").move_left() end, mode = { "n", "v" }, desc = "Move left" },
            { "gl", function() require("treewalker").move_right() end, mode = { "n", "v" }, desc = "Move right" },
            { "sk", function() require("treewalker").swap_up() end, mode = "n", desc = "Swap up" },
            { "sj", function() require("treewalker").swap_down() end, mode = "n", desc = "Swap down" },
            { "sh", function() require("treewalker").swap_left() end, mode = "n", desc = "Swap left" },
            { "sl", function() require("treewalker").swap_right() end, mode = "n", desc = "Swap right" },
        },
    },
    -- Ideally this should be enabled before mason-installer
    { "zapling/mason-lock.nvim", opts = {}, event = "VeryLazy" },
}

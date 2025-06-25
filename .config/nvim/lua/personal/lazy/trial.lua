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
    {
        "echasnovski/mini.snippets",
        version = "*",
        lazy = true,
        opts = function(_, opts)
            local snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")
            opts.snippets = {
                snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
                snippets.gen_loader.from_lang(),
            }
        end,
    },
    {
        "danymat/neogen",
        dependencies = { "echasnovski/mini.snippets" },
        keys = {
            { "nf", function() require("neogen").generate() end, desc = "Generate docstring" },
        },
        opts = {
            snippet_engine = "mini",
            languages = {
                lua = { template = { annotation_convention = "emmylua" } },
                python = { template = { annotation_convention = "numpydoc" } },
            },
        },
    },
    {
        "saghen/blink.cmp",
        dependencies = { "echasnovski/mini.snippets", "rafamadriz/friendly-snippets" },
        opts = { snippets = { preset = "mini_snippets" } },
    },
}

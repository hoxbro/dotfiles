return {
    {
        "Wansmer/treesj",
        keys = {
            {
                "<leader>cs",
                function() require("treesj").toggle() end,
                desc = "Treesitter split and join",
                mode = { "n", "x" },
            },
        },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = { use_default_keymaps = false },
    },
}

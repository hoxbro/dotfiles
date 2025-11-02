return {
    {
        "saghen/blink.cmp",
        event = "VeryLazy",
        version = "1.*",
        opts_extend = { "sources.default" },
        dependencies = { "nvim-mini/mini.snippets", "rafamadriz/friendly-snippets" },
        opts = {
            completion = {
                documentation = { auto_show = false },
                accept = { auto_brackets = { enabled = false } },
            },
            sources = {
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                },
            },
            fuzzy = { sorts = { "exact", "score", "sort_text" } },
            signature = { enabled = true },
            keymap = { ["<C-e>"] = { "hide", "show" } },
            snippets = { preset = "mini_snippets" },
        },
    },
    {
        "nvim-mini/mini.snippets",
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
}

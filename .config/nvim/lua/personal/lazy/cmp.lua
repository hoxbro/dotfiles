return {
    {
        "saghen/blink.cmp",
        event = "VeryLazy",
        version = "1.*",
        opts = {
            completion = {
                documentation = { auto_show = false },
                accept = { auto_brackets = { enabled = false } },
            },
            sources = {
                default = { "lazydev", "lsp", "path", "buffer", "snippets", "copilot" },
                providers = {
                    copilot = { name = "copilot", module = "blink-copilot", score_offset = 100, async = true },
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                },
            },
            fuzzy = { sorts = { "exact", "score", "sort_text" } },
            signature = { enabled = true },
            keymap = { ["<C-e>"] = { "hide", "show" } },
        },
    },
}

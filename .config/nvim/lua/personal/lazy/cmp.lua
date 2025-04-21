return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        opts = {
            completion = { documentation = { auto_show = false } },
            sources = {
                default = { "lazydev", "lsp", "path", "buffer", "snippets", "copilot" },
                providers = {
                    copilot = { name = "copilot", module = "blink-copilot", score_offset = 100, async = true },
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                },
            },
            signature = { enabled = true },
        },
    },
}

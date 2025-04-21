return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        opts = {
            completion = { documentation = { auto_show = false } },
            enabled = function()
                local filetype = vim.bo.filetype
                return filetype ~= "prompt" or vim.startswith(filetype, "dapui_") or filetype == "dap-repl"
            end,
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

local download = function()
    local download = require("blink.cmp.fuzzy.download")
    local files = require("blink.cmp.fuzzy.download.files")

    -- Avoid EEXIST error
    vim.fn.mkdir(files.lib_folder, "p")

    print("Downloading pre-built binary\n")
    download.ensure_downloaded(function()
        print("Finished downloading pre-built binary\n")
        vim.defer_fn(function() vim.cmd("qa!") end, 10)
    end)
end
vim.api.nvim_create_user_command("BlinkDownload", download, { desc = "Download binary" })

return {
    {
        "saghen/blink.cmp",
        event = "VeryLazy",
        version = "1.*",
        opts_extend = { "default.providers" },
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

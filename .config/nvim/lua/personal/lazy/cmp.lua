local download = function()
    local download = require("blink.cmp.fuzzy.download")
    local files = require("blink.cmp.fuzzy.download.files")

    -- Avoid EEXIST error
    vim.fn.mkdir(files.lib_folder, "p")

    local done = false
    print("Downloading pre-built binary\n")
    download.ensure_downloaded(function()
        print("Finished downloading pre-built binary\n")
        done = true
    end)
    vim.wait(60000, function() return done end, 1000, false)
end
vim.api.nvim_create_user_command("BlinkDownload", download, { desc = "Download binary" })

return {
    {
        "saghen/blink.cmp",
        event = "VeryLazy",
        version = "1.*",
        opts_extend = { "sources.default" },
        dependencies = { "echasnovski/mini.snippets", "rafamadriz/friendly-snippets" },
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
}

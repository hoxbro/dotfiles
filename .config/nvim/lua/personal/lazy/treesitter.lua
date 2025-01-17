return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
        cmd = { "TSUpdateSync", "TSUpdate" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 10 } },
        },
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            ensure_installed = {
                "lua",
                "python",
                "rust",
                "javascript",
                "typescript",
                "vimdoc",
                "vim",
                "bash",
                "html",
                "css",
                "yaml",
                "toml",
                "sql",
                "markdown",
                "markdown_inline",
                "query",
            },

            auto_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        },
    },
}

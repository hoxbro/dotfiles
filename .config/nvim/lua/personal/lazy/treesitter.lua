return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
        cmd = { "TSUpdateSync", "TSUpdate" },
        branch = "main",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
            { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 10 } },
        },
        build = ":TSUpdate",
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
                "dockerfile",
                "nginx",
            },
        },
        config = function(_, opts)
            require("nvim-treesitter").setup()

            -- Install parsers
            local installed = require("nvim-treesitter.config").get_installed()
            local to_install = vim.iter(opts.ensure_installed)
                :filter(function(parser) return not vim.tbl_contains(installed, parser) end)
                :totable()
            if #to_install > 0 then require("nvim-treesitter").install(to_install) end

            -- Autostart
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(details)
                    local bufnr = details.buf
                    -- Highlight
                    if not pcall(vim.treesitter.start, bufnr) then return end
                    -- Indentation
                    vim.bo[bufnr].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                    -- Folds
                    vim.bo[bufnr].syntax = "on"
                    vim.wo.foldlevel = 99
                    vim.wo.foldmethod = "expr"
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                end,
            })
        end,
    },
    {
        "wansmer/treesj",
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

return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    event = { "BufWritePre" },
    keys = {
        {
            "<leader>f",
            function() require("conform").format({ async = true }) end,
            desc = "Format Code",
            mode = { "n", "x" },
        },
    },
    dependencies = {
        {
            "williamboman/mason.nvim",
            opts = { install = { "stylua", "ruff", "prettierd", "shfmt", "eslint_d", "taplo" } },
        },
    },
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            python = { "ruff_fix", "ruff_format", "injected" },
            javascript = { "prettierd", "eslint_d" },
            typescript = { "prettierd", "eslint_d" },
            html = { "prettierd" },
            rust = { "rustfmt" },
            css = { "prettierd" },
            markdown = { "prettierd", "injected" },
            json = { "prettierd" },
            yaml = { "prettierd" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            zsh = { "shfmt" },
            toml = { "taplo" },
            -- ["*"] = { "injected" },
        },
        format_on_save = {
            formatters = { "trim_whitespace", "trim_newlines" },
        },
        formatters = {
            shfmt = { prepend_args = { "-i", "4" } },
            prettierd = { prepend_args = { "--single-quote=false" } },
            taplo = {
                append_args = {
                    "--option",
                    "align_comments=false",
                    "--option",
                    "indent_string=    ",
                    "--option",
                    "column_width=100",
                },
            },
        },
    },
}

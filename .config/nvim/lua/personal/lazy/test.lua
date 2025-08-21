return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/fixcursorhold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/nvim-nio",
        },
        commit = "52fca6717ef972113ddd6ca223e30ad0abb2800c", -- https://github.com/nvim-neotest/neotest/issues/531
        keys = {
            {
                "<F7>",
                ---@diagnostic disable-next-line: missing-fields
                function() require("neotest").run.run({ strategy = "dap" }) end,
                desc = "Debug: nearest test",
            },
            {
                "<leader>tr",
                function() require("neotest").run.run() end,
                desc = "Run The Nearest Test",
            },
            {
                "<leader>tf",
                function() require("neotest").run.run(vim.fn.expand("%")) end,
                desc = "Run All Test in File",
            },
            {
                "<leader>to",
                function() require("neotest").output.open({ enter = true }) end,
                desc = "Enter Test Output",
            },
            {
                "<leader>ts",
                function() require("neotest").summary.toggle() end,
                desc = "Get Test Summary",
            },
        },
        -- `opts` are a table where:
        --
        --  - Keys (`String`) are the module name, e.g., `["neotest-python"]`.
        --  - Values (`Table`) are the opts for the setup of the adapter.
        config = function(_, opts)
            local adapters = {}
            for adapter_name, adapter_opts in pairs(opts) do
                table.insert(adapters, require(adapter_name)(adapter_opts))
            end

            ---@diagnostic disable-next-line: missing-fields
            require("neotest").setup({ adapters = adapters })
        end,
    },
}

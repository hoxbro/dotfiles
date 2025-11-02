return {
    { "tpope/vim-sleuth", event = { "BufReadPost", "BufWritePost", "BufNewFile" } },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
        keys = {
            {
                "<leader>dd",
                function() require("trouble").toggle({ mode = "diagnostics" }) end,
                desc = "Trouble Toggle console",
            },
        },
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = {
            signs = false,
            highlight = { pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]] },
        },
    },
    {
        "folke/snacks.nvim",
        lazy = false,
        priority = 998,
        keys = {
            { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
            { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
        },
        opts = { scratch = { ft = "markdown" }, quickfile = {}, bigfile = {} },
    },
    {
        -- Better Around/Inside textobjects
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [']quote
        --  - ci'  - [C]hange [I]nside [']quote
        "nvim-mini/mini.ai",
        version = "*",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = { n_lines = 500 },
    },
    {
        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        "nvim-mini/mini.surround",
        version = "*",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        opts = { mappings = { highlight = "" } },
    },
    {
        "mbbill/undotree",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        keys = { { "<leader>u", function() vim.cmd.UndotreeToggle() end, desc = "Undotree" } },
    },
    { "laytan/cloak.nvim", event = { "BufReadPre" }, opts = {} },
    "lewis6991/fileline.nvim",
}

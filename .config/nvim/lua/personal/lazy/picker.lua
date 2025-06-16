local exclude = {
    ".git/",
    "__pycache__/",
    ".ipynb_checkpoints/",
    "formal/",
    "archive/",
    "patch/",
    "*_cache/",
    ".pixi/",
    "node_modules/",
    ".venv/",

    "lazy-lock.json",
    "pixi.lock",
    "uv.lock",

    "*.ipynb",
    "*.png",
    "*.jpeg",
    "*.jpg",
    "*.zip",
    "*.csv",
    "*.db",
    "*.blf",
    "*.svg",
    "*.log",
    "*.gif",

    -- Config submodules
    "zsh-autosuggestions/",
    "zsh-syntax-highlighting/",
    "diff-so-fancy/",
    "zsh-defer/",
}

return {
    "folke/snacks.nvim",
    keys = {
        {
            "<leader>sb",
            function() require("snacks").picker.buffers() end,
            desc = "Find Existing Buffers",
        },
        {
            "<leader>gf",
            function() require("snacks").picker.git_diff() end,
            desc = "Search Git Status",
        },
        {
            "<leader>sd",
            function() require("snacks").picker.diagnostics() end,
            desc = "Search Diagnostics",
        },
        {
            "<leader>sr",
            function() require("snacks").picker.registers() end,
            desc = "Search Registers",
        },
        {
            "<leader>/",
            function() require("snacks").picker.lines({ layout = "default" }) end,
            desc = "Fuzzily Search In Current Buffer",
        },
        {
            "<leader>sf",
            function() require("snacks").picker.files() end,
            desc = "Search Files",
        },
        {
            "<leader>sg",
            function() require("snacks").picker.grep() end,
            desc = "Search By Grep",
        },
        {
            "<leader>sh",
            function() require("snacks").picker.files({ cwd = vim.fn.getenv("HOLOVIZ_DEV"), title = "Files HoloViz" }) end,
            desc = "Search Files (Holoviz)",
        },
        {
            "<leader>sj",
            function() require("snacks").picker.grep({ cwd = vim.fn.getenv("HOLOVIZ_DEV"), title = "Grep HoloViz" }) end,
            desc = "Search Files (Holoviz)",
        },
        {
            "<leader>sk",
            function() require("snacks").picker.keymaps() end,
            desc = "Search keymaps",
        },
        {
            "<leader>sl",
            function() require("snacks").picker.resume() end,
            desc = "Last search",
        },
    },
    opts = {
        picker = {
            exclude = exclude,
            sources = {
                files = { hidden = true, follow = true },
                grep = { hidden = true, follow = true },
            },
            previewers = {
                diff = { builtin = false, cmd = { "__dsf" } },
            },
        },
        input = { win = { row = 10 } },
    },
}

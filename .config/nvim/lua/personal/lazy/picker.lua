local exclude = {
    ".git/",
    "__pycache__/",
    ".ipynb_checkpoints/",
    "formal/",
    "archive/",
    "patch/",
    ".*_cache/",
    ".pixi/",
    "node_modules/",
    ".venv/",
    ".claude/",

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
            function() Snacks.picker.buffers() end,
            desc = "Find Existing Buffers",
        },
        {
            "<leader>gf",
            function() Snacks.picker.git_diff() end,
            desc = "Search Git Status",
        },
        {
            "<leader>sd",
            function() Snacks.picker.diagnostics() end,
            desc = "Search Diagnostics",
        },
        {
            "<leader>sr",
            function() Snacks.picker.registers() end,
            desc = "Search Registers",
        },
        {
            "<leader>/",
            function() Snacks.picker.lines({ layout = "default" }) end,
            desc = "Fuzzily Search In Current Buffer",
        },
        {
            "<leader>sf",
            function() Snacks.picker.smart() end,
            desc = "Search Files",
        },
        {
            "<leader>sg",
            function() Snacks.picker.grep() end,
            desc = "Search By Grep",
        },
        {
            "<leader>sg",
            function()
                vim.cmd('normal! "zy')
                local query = vim.trim(vim.fn.getreg("z"))
                Snacks.picker.grep({ search = query })
            end,
            desc = "Search By Grep",
            mode = "v",
        },
        {
            "<leader>sh",
            function() Snacks.picker.files({ cwd = vim.fn.getenv("HOLOVIZ_DEV"), title = "Files HoloViz" }) end,
            desc = "Search Files (Holoviz)",
        },
        {
            "<leader>sj",
            function() Snacks.picker.grep({ cwd = vim.fn.getenv("HOLOVIZ_DEV"), title = "Grep HoloViz" }) end,
            desc = "Search Files (Holoviz)",
        },
        {
            "<leader>sk",
            function() Snacks.picker.keymaps() end,
            desc = "Search keymaps",
        },
        {
            "<leader>sl",
            function() Snacks.picker.resume() end,
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
                diff = { style = "terminal", cmd = { "__dsf" } },
            },
        },
        input = { win = { row = 10 } },
    },
}

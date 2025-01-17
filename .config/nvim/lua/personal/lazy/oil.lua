local always_hidden = {
    ".SynologyWorkingDirectory",
    ".benchmarks",
    ".git",
    -- ".hypothesis*",
    ".ipynb_checkpoints",
    ".pixi",
    ".pytest_cache",
    ".ruff_cache",
    ".mypy_cache",
    "CVS",
    "__pycache__",
    "node_modules",
    ".obsidian",
}

return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    opts = {
        columns = { "icon" },
        delete_to_trash = true,
        skip_confim_for_simple_edits = true,
        view_options = {
            show_hidden = true,
            natural_order = true,
            is_always_hidden = function(name, _) return vim.tbl_contains(always_hidden, name) end,
        },
        keymaps = { ["<C-c>"] = false },
    },
    keys = { { "<leader>-", "<CMD>Oil<CR>", desc = "Open parent directory" } },
}

local always_hidden = {
    ".benchmarks",
    ".git",
    ".ipynb_checkpoints",
    ".pixi",
    ".pytest_cache",
    ".ruff_cache",
    ".mypy_cache",
    "CVS",
    "__pycache__",
    "node_modules",
    ".venv",
    ".hypothesis",
    ".claude",
}

local function get_git_branch()
    local git_branch = vim.fn.systemlist("git branch --show-current")
    if git_branch[1] == "fatal: not a git repository (or any of the parent directories): .git" then return nil end
    return git_branch[1]
end

local function harpoon_list()
    local branch = get_git_branch()
    if branch == nil then
        return _G.__harpoon:list()
    else
        return _G.__harpoon:list(branch)
    end
end

return {
    {
        "theprimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        branch = "harpoon2",
        config = function() _G.__harpoon = require("harpoon"):setup() end,
        keys = {
            { "<leader>a", function() harpoon_list():add() end, desc = "Add to Harpoon" },
            {
                "<leader>e",
                function() _G.__harpoon.ui:toggle_quick_menu(harpoon_list()) end,
                desc = "Edit Harpoon List",
            },
            { "<leader>h", function() harpoon_list():select(1) end, desc = "First Item on Harpoon List" },
            { "<leader>j", function() harpoon_list():select(2) end, desc = "Second Item on Harpoon List" },
            { "<leader>k", function() harpoon_list():select(3) end, desc = "Third Item on Harpoon List" },
            { "<leader>l", function() harpoon_list():select(4) end, desc = "Fourth Item on Harpoon List" },
        },
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VimEnter",
        opts = {
            columns = { "icon" },
            delete_to_trash = true,
            skip_confirm_for_simple_edits = true,
            view_options = {
                show_hidden = true,
                natural_order = true,
                is_always_hidden = function(name, _) return vim.tbl_contains(always_hidden, name) end,
            },
            keymaps = { ["<C-c>"] = false },
        },
        keys = { { "<leader>-", "<CMD>Oil<CR>", desc = "Open parent directory" } },
    },
}

local function get_git_branch()
    local git_branch = vim.fn.systemlist("git branch --show-current")
    if git_branch[1] == "fatal: not a git repository (or any of the parent directories): .git" then return nil end
    return git_branch[1]
end

local harpoon -- To be able to lazy load it

local function harpoon_list()
    local branch = get_git_branch()
    if branch == nil then
        return harpoon:list()
    else
        return harpoon:list(branch)
    end
end

return {
    "theprimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    branch = "harpoon2",
    config = function() harpoon = require("harpoon"):setup() end,
    keys = {
        { "<leader>a", function() harpoon_list():add() end, desc = "Add to Harpoon" },
        { "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon_list()) end, desc = "Edit Harpoon List" },
        { "<leader>h", function() harpoon_list():select(1) end, desc = "First Item on Harpoon List" },
        { "<leader>j", function() harpoon_list():select(2) end, desc = "Second Item on Harpoon List" },
        { "<leader>k", function() harpoon_list():select(3) end, desc = "Third Item on Harpoon List" },
        { "<leader>l", function() harpoon_list():select(4) end, desc = "Fourth Item on Harpoon List" },
    },
}

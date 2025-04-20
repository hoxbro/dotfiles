-- From: https://www.reddit.com/r/neovim/comments/1jv03t1/simple_yankring/
-- Shift numbered registers up (1 becomes 2, etc.)
local function yank_shift()
    for i = 9, 1, -1 do
        vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
    end
end

-- Create autocmd for TextYankPost event
local yank_group = vim.api.nvim_create_augroup("yank_group", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = yank_group,
    callback = function()
        local event = vim.v.event
        if event.operator == "y" then yank_shift() end
    end,
})

for i = 1, 9 do
    vim.keymap.set("n", i .. "p", '"' .. i .. "p", { noremap = true, desc = "Paste from register " .. i })
    vim.keymap.set("n", i .. "P", '"' .. i .. "P", { noremap = true, desc = "Paste before from register " .. i })
end

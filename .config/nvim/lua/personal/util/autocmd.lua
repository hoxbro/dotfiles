-- Run program inside vim
vim.keymap.set({ "n", "i", "v", "t" }, "<F1>", "<nop>")
local group = vim.api.nvim_create_augroup("runme", { clear = true })
local function run_cmd(pattern, command)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = pattern,
        group = group,
        callback = function()
            vim.keymap.set("n", "<F1>", ":w<CR>:" .. command .. " %<CR>", { noremap = true, silent = true })
        end,
    })
end

run_cmd("python", "!python3")
run_cmd("sh", "!bash")
run_cmd("javascript", "!node")
run_cmd("lua", "source")

-- Change directory to the file's directory
local group_cdpwd = vim.api.nvim_create_augroup("group_cdpwd", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
    group = group_cdpwd,
    pattern = "*",
    callback = function()
        local path = vim.fn.resolve(vim.v.argv[3])
        if path == "." or vim.fn.isdirectory(path) == 0 then return end
        vim.api.nvim_set_current_dir(path)
    end,
})

-- Because I'm stupid
vim.api.nvim_create_user_command("W", "w", {})

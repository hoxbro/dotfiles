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

run_cmd("python", "!python")
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
local typos = { "W", "Wq", "WQ", "Wqa", "WQa", "WQA", "WqA", "Q", "Qa", "QA" }
for _, cmd in ipairs(typos) do
    vim.api.nvim_create_user_command(
        cmd,
        function(opts) vim.api.nvim_cmd({ cmd = cmd:lower(), bang = opts.bang, mods = { noautocmd = true } }, {}) end,
        { bang = true }
    )
end

-- Ruff to quicklist
local ruff_quicklist = function()
    local output = vim.fn.systemlist({
        vim.fn.exepath("ruff"),
        "check",
        "--no-fix",
        "--exit-zero",
        "--exclude",
        "*.ipynb",
        "--output-format",
        "concise",
        vim.fn.getcwd(),
    })

    if vim.fn.match(output[1] or "", "All checks passed!") ~= -1 then
        -- Just print the output if all checks passed
        print(table.concat(output, "\n"))
    else
        -- Load output into quickfix list
        local qf_entries = {}
        for _, line in ipairs(output) do
            local filename, lnum, col, text = line:match("^(.-):(%d+):(%d+):%s*(.*)")
            if filename then
                table.insert(qf_entries, {
                    filename = filename,
                    lnum = tonumber(lnum),
                    col = tonumber(col),
                    text = text,
                })
            end
        end
        vim.fn.setqflist({}, " ", { title = "Ruff", items = qf_entries })
        vim.cmd("copen")
        vim.cmd("cfirst")
    end
end

vim.api.nvim_create_user_command("RuffQuickfix", ruff_quicklist, {})

-- Paste to clipboard on focus
-- https://www.reddit.com/r/neovim/comments/1l4tubm/copy_last_yanked_text_to_clipboard_on_focuslost/
local last_clipboard = vim.fn.getreg("0")
local group_clipboard = vim.api.nvim_create_augroup("group_clipboard", { clear = true })
local skip_reset = false

-- Reset last_clipboard on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Reset last_clipboard on yank",
    group = group_clipboard,
    callback = function()
        if not skip_reset then last_clipboard = "" end
    end,
})

vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
    desc = "Copy to clipboard on FocusLost",
    group = group_clipboard,
    callback = function()
        local cur_clipboard = vim.fn.getreg("0")
        if cur_clipboard ~= last_clipboard then
            vim.fn.setreg("+", cur_clipboard)
            last_clipboard = cur_clipboard
            skip_reset = true
            vim.defer_fn(function() skip_reset = false end, 10)
        end
    end,
})

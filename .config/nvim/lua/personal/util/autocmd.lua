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

-- Paste to clipboard on focus
-- https://www.reddit.com/r/neovim/comments/1l4tubm/copy_last_yanked_text_to_clipboard_on_focuslost/
local last_clipboard
local group_clipboard = vim.api.nvim_create_augroup("group_clipboard", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
    desc = "Wait for shada load",
    group = group_clipboard,
    callback = function() last_clipboard = vim.fn.getreg("0") end,
})

vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
    desc = "Copy to clipboard on FocusLost",
    group = group_clipboard,
    callback = function()
        local cur_clipboard = vim.fn.getreg("0")
        if cur_clipboard ~= "" and cur_clipboard ~= last_clipboard then
            if vim.env.SSH_TTY then
                vim.fn.system("copy", cur_clipboard)
            else
                vim.fn.setreg("+", cur_clipboard)
            end
            last_clipboard = cur_clipboard
        end
    end,
})

-- Shebang linter
local ns = vim.api.nvim_create_namespace("shebang-env")
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    pattern = "*",
    group = vim.api.nvim_create_augroup("shebang-env", { clear = true }),
    callback = function(args)
        local filepath = vim.api.nvim_buf_get_name(args.buf)
        if filepath == "" then return end

        local stat = (vim.uv or vim.loop).fs_stat(filepath)
        if not stat or bit.band(stat.mode, 64) == 0 then
            vim.diagnostic.set(ns, args.buf, {}, {})
            return
        end

        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)
        local first = lines[1] or ""

        if not first:match("^#!/usr/bin/env%s+%S+$") then
            vim.diagnostic.set(ns, args.buf, {
                {
                    lnum = 0,
                    col = 0,
                    message = "Shebang should use #!/usr/bin/env <interpreter>",
                    severity = vim.diagnostic.severity.WARN,
                },
            }, {})
        else
            vim.diagnostic.set(ns, args.buf, {}, {})
        end
    end,
})

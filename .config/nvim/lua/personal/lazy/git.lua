local function switch_worktree(new_root)
    local old_root
    for _, wt in
        ipairs(vim.json.decode(vim.fn.system({ "wt", "list", "--format=json" }), { luanil = { object = true } }).items)
    do
        if wt.worktree and wt.worktree.current then old_root = wt.worktree.path end
    end
    if not old_root or old_root == new_root then return end

    for _, client in ipairs(vim.lsp.get_clients()) do
        client:stop()
    end
    vim.cmd.cd(new_root)

    local skipped = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local prefix, name = vim.api.nvim_buf_get_name(buf):match("^(%a*:?/?/?)(/.*)$")
        local is_oil = prefix == "oil://"
        if
            name
            and (prefix == "" or is_oil)
            and (vim.bo[buf].buflisted or is_oil)
            and vim.startswith(name, old_root .. "/")
        then
            if vim.bo[buf].modified then
                table.insert(skipped, vim.fn.fnamemodify(name, ":~"))
            else
                local new_name = new_root .. name:sub(#old_root + 1)
                if vim.uv.fs_stat(new_name) then
                    local wins = vim.fn.win_findbuf(buf)
                    for _, win in ipairs(wins) do
                        vim.api.nvim_win_call(win, function() vim.cmd.edit(vim.fn.fnameescape(prefix .. new_name)) end)
                    end
                    if #wins == 0 and not is_oil then vim.bo[vim.fn.bufadd(new_name)].buflisted = true end
                end
                if vim.api.nvim_buf_is_valid(buf) and #vim.fn.win_findbuf(buf) == 0 then
                    vim.api.nvim_buf_delete(buf, {})
                end
            end
        end
    end

    vim.notify("Switched to " .. vim.fn.fnamemodify(new_root, ":~"))
    if #skipped > 0 then vim.notify("Kept modified buffers:\n" .. table.concat(skipped, "\n"), vim.log.levels.WARN) end
end

return {
    {
        "tpope/vim-fugitive",
        cmd = "Git",
        keys = {
            { "<leader>gs", function() vim.cmd.Git() end, desc = "Open Git Status" },
            { "<leader>gb", function() vim.cmd.Git("blame") end, desc = "Open Git Blame" },
            {
                "<leader>gq",
                function()
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        local buf_name = vim.api.nvim_buf_get_name(buf)
                        if buf_name:find("fugitive") then vim.api.nvim_win_close(win, true) end
                    end
                end,
                desc = "Close all Git Browser",
                mode = { "n", "v" },
            },
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufWritePost" },
        keys = {
            { "<leader>gd", function() require("gitsigns").preview_hunk_inline() end, desc = "Git Preview Hunk" },
            { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Git Reset Hunk" },
        },
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
                local gs = require("gitsigns")

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map({ "n", "v" }, "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.nav_hunk("next") end)
                    return "<Ignore>"
                end, { expr = true, desc = "Jump to next hunk" })

                map({ "n", "v" }, "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.nav_hunk("prev") end)
                    return "<Ignore>"
                end, { expr = true, desc = "Jump to previous hunk" })
            end,
        },
    },
    {
        "dlyongemallo/diffview-plus.nvim",
        cmd = "DiffviewOpen",
        opts = function()
            local actions = require("diffview.actions")
            local view = {
                { "n", "co", actions.conflict_choose("ours"), { desc = "Choose ours" } },
                { "n", "ct", actions.conflict_choose("theirs"), { desc = "Choose theirs" } },
                { "n", "cn", actions.conflict_choose("base"), { desc = "Choose none" } },
                { "n", "cb", actions.conflict_choose("all"), { desc = "Choose both" } },
                { "n", "cf", function() require("diffview").emit("focus_files") end, { desc = "Goto files" } },
            }
            return { view = { merge_tool = { layout = "diff4_mixed" } }, keymaps = { view = view } }
        end,
    },
    {
        "folke/snacks.nvim",
        keys = {
            { "<leader>gw", function() Snacks.gitbrowse() end, desc = "Open Git Browser", mode = { "n", "v" } },
            {
                "<leader>wt",
                function()
                    local out = vim.fn.system({ "wt", "list", "--format=json" })
                    if vim.v.shell_error ~= 0 then return vim.notify("Not a git repository", vim.log.levels.WARN) end
                    local items = {}
                    for _, wt in ipairs(vim.json.decode(out, { luanil = { object = true } }).items) do
                        if wt.worktree and vim.uv.fs_stat(wt.worktree.path) then
                            local branch = wt.branch or "(detached)"
                            table.insert(items, {
                                text = branch .. " " .. wt.worktree.path,
                                path = wt.worktree.path,
                                branch = branch,
                                symbols = wt.display and wt.display.symbols or "",
                            })
                        end
                    end
                    Snacks.picker.pick({
                        title = "Git Worktrees",
                        items = items,
                        layout = { preset = "select" },
                        format = function(item)
                            return {
                                { ("%-30s"):format(item.branch), "SnacksPickerGitBranch" },
                                { ("%-6s"):format(item.symbols), "SnacksPickerGitStatus" },
                                { vim.fn.fnamemodify(item.path, ":~"), "SnacksPickerDir" },
                            }
                        end,
                        confirm = function(picker, item)
                            picker:close()
                            if item then switch_worktree(item.path) end
                        end,
                    })
                end,
                desc = "Switch Git Worktree",
            },
        },
        opts = { gitbrowse = {} },
    },
}

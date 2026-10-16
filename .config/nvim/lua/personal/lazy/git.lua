local function switch_worktree(new_root)
    local old_root = vim.trim(vim.fn.system({ "git", "rev-parse", "--show-toplevel" }))
    if old_root == new_root then return end

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
        "esmuellert/codediff.nvim",
        cmd = "CodeDiff",
        opts = {
            diff = { conflict_result_position = "center", conflict_result_width_ratio = { 1, 1, 1 } },
            explorer = { hidden = true },
        },
    },
    {
        "folke/snacks.nvim",
        keys = {
            { "<leader>gw", function() Snacks.gitbrowse() end, desc = "Open Git Browser", mode = { "n", "v" } },
            {
                "<leader>sw",
                function()
                    local out = vim.fn.systemlist({ "git", "worktree", "list", "--porcelain" })
                    if vim.v.shell_error ~= 0 then return vim.notify("Not a git repository", vim.log.levels.WARN) end
                    local items = {}
                    for _, line in ipairs(out) do
                        local path = line:match("^worktree (.+)")
                        if path then table.insert(items, { text = path, path = path, branch = "" }) end
                        local branch = line:match("^branch refs/heads/(.+)")
                        if branch then items[#items].branch = branch end
                        if line == "detached" then items[#items].branch = "(detached)" end
                        if line == "bare" then items[#items].branch = "(bare)" end
                    end
                    items = vim.tbl_filter(function(item) return vim.uv.fs_stat(item.path) ~= nil end, items)
                    Snacks.picker.pick({
                        title = "Git Worktrees",
                        items = items,
                        layout = { preset = "select" },
                        format = function(item)
                            return {
                                { ("%-30s"):format(item.branch), "SnacksPickerGitBranch" },
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
            -- { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
            -- { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
            -- { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
            -- {
            --     "<leader>gP",
            --     function() Snacks.picker.gh_pr({ state = "all" }) end,
            --     desc = "GitHub Pull Requests (all)",
            -- },
        },
        opts = { gitbrowse = {} }, -- gh = {}
    },
}

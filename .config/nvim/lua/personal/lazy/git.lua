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
            { "<leader>gp", function() require("gitsigns").preview_hunk_inline() end, desc = "Git Preview Hunk" },
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
        "sindrets/diffview.nvim",
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
            return { keymaps = { view = view } }
        end,
    },
    {
        "folke/snacks.nvim",
        keys = {
            {
                "<leader>gw",
                function() require("snacks.gitbrowse")() end,
                desc = "Open Git Browser",
                mode = { "n", "v" },
            },
        },
        opts = { gitbrowse = {} },
    },
}

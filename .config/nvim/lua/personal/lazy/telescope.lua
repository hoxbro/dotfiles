local git_status_keymap = function(bufnr)
    -- https://github.com/nvim-telescope/telescope.nvim/issues/3341
    require("telescope.actions").select_default(bufnr)
    local ok = false
    local id
    id = vim.api.nvim_create_autocmd("User", {
        pattern = "GitSignsUpdate",
        callback = function()
            if ok then vim.api.nvim_del_autocmd(id) end
            require("gitsigns").nav_hunk("first", { navigation_message = false })
            ok = true
        end,
    })
end

local holoviz_opts = function(title)
    local dir = vim.fn.getenv("HOLOVIZ_DEV")
    return {
        search_dirs = { dir },
        prompt_title = title,
        follow = true,
        hidden = true,
        path_display = function(_, path)
            return require("telescope.utils").transform_path(
                { path_display = { "filename_first" } },
                path:gsub(dir, "")
            )
        end,
    }
end

return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function() return vim.fn.executable("make") == 1 end,
        },
    },
    keys = {
        {
            "<leader>so",
            function() require("telescope.builtin").oldfiles() end,
            desc = "Find Recently Opened Files",
        },
        {
            "<leader>sb",
            function() require("telescope.builtin").buffers() end,
            desc = "Find Existing Buffers",
        },
        {
            "<leader>gf",
            function() require("telescope.builtin").git_status() end,
            desc = "Search Git Status",
        },
        {
            "<leader>sw",
            function() require("telescope.builtin").grep_string() end,
            desc = "Search Current Word",
        },
        {
            "<leader>sd",
            function() require("telescope.builtin").diagnostics() end,
            desc = "Search Diagnostics",
        },
        {
            "<leader>sr",
            function() require("telescope.builtin").registers() end,
            desc = "Search Registers",
        },
        {
            "<leader>/",
            function() require("telescope.builtin").current_buffer_fuzzy_find() end,
            desc = "Fuzzily Search In Current Buffer",
        },
        {
            "<leader>sf",
            function() require("telescope.builtin").find_files({ follow = true, hidden = true }) end,
            desc = "Search Files",
        },
        {
            "<leader>sg",
            function() require("telescope.builtin").live_grep() end,
            desc = "Search By Grep",
        },
        {
            "<leader>sh",
            function() require("telescope.builtin").find_files(holoviz_opts("Search Files (Holoviz)")) end,
            desc = "Search Files (Holoviz)",
        },
        {
            "<leader>sj",
            function() require("telescope.builtin").live_grep(holoviz_opts("Live Grep (Holoviz)")) end,
            desc = "Live Grep (Holoviz)",
        },
        {
            "<leader>sk",
            function() require("telescope.builtin").keymaps() end,
            desc = "Search keymaps",
        },
    },
    opts = function()
        local actions = require("telescope.actions")
        return {
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                },
                path_display = { "filename_first" },
                mappings = {
                    i = {
                        ["<C-r>"] = function() require("telescope.builtin").resume() end,
                        ["<C-f>"] = actions.to_fuzzy_refine,
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<C-n>"] = actions.cycle_history_next,
                    },
                },
            },
            pickers = { git_status = { mappings = { i = { ["<cr>"] = git_status_keymap } } } },
            extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
        }
    end,
    config = function(_, opts)
        require("telescope").setup(opts)
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("ui-select")
    end,
}

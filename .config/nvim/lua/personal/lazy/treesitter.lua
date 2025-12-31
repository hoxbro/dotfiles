local indents = {
    css = 2,
    javascript = 2,
    python = 4,
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
        branch = "main",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
            { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 10 } },
            { "williamboman/mason.nvim", opts = { install = { "tree-sitter-cli" } } },
        },
        build = function()
            if vim.fn.exepath("tree-sitter") == "" then return end
            require("nvim-treesitter").update()
        end,
        opts_extend = { "install" },
        opts = { install = { "json", "sql", "toml", "xml", "yaml" } },
        config = function(_, opts)
            require("nvim-treesitter").setup()

            -- Install parsers
            local installed = require("nvim-treesitter.config").get_installed()
            local to_install = vim.iter(opts.install or {})
                :filter(function(parser) return not vim.tbl_contains(installed, parser) end)
                :totable()
            if #to_install > 0 then
                local installers = require("nvim-treesitter").install(to_install)
                local is_headless = #vim.api.nvim_list_uis() == 0
                if is_headless then installers:wait(600000) end
            end

            -- Autostart
            local autostart_group = vim.api.nvim_create_augroup("TreesitterAutoStart", { clear = true })
            local autostart = function(details)
                local bufnr = details.buf
                -- Highlight
                if not pcall(vim.treesitter.start, bufnr) then return end
                -- Indentation
                vim.bo[bufnr].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                -- Folds
                vim.bo[bufnr].syntax = "on"
                vim.wo.foldlevel = 99
                vim.wo.foldmethod = "expr"
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            end
            vim.api.nvim_create_autocmd("FileType", {
                group = autostart_group,
                callback = autostart,
            })

            -- Auto update indent settings based on language
            local last_lang = nil
            local function update_indent_on_lang_change()
                local ok, parser = pcall(vim.treesitter.get_parser, 0)
                if not ok or not parser then return end

                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                row, col = row - 1, col
                local ltree = parser:language_for_range({ row, col, row, col })
                local lang = ltree:lang()
                if lang ~= last_lang then
                    last_lang = lang
                    local indent = indents[lang]

                    if indent then
                        vim.bo.tabstop = indent
                        vim.bo.shiftwidth = indent
                    end
                end
            end
            local indent_group = vim.api.nvim_create_augroup("TreesitterIndent", { clear = true })
            vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter" }, {
                group = indent_group,
                callback = update_indent_on_lang_change,
            })
        end,
    },
    {
        "wansmer/treesj",
        keys = {
            {
                "<leader>cs",
                function() require("treesj").toggle() end,
                desc = "Treesitter split and join",
                mode = { "n", "x" },
            },
            {
                "<leader>cS",
                function() require("treesj").split() end,
                desc = "Treesitter split",
                mode = { "n", "x" },
            },
        },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = { use_default_keymaps = false },
    },
}

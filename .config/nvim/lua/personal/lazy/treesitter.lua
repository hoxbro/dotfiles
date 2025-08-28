local indents = {
    css = 2,
    javascript = 2,
    python = 4,
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufWritePost", "BufNewFile", "VeryLazy" },
        cmd = { "TSUpdateSync", "TSUpdate" },
        branch = "main",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
            { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 10 } },
        },
        build = ":TSUpdate",
        opts = {
            ensure_installed = {
                "lua",
                "python",
                "rust",
                "javascript",
                "typescript",
                "vimdoc",
                "vim",
                "bash",
                "html",
                "css",
                "yaml",
                "toml",
                "sql",
                "markdown",
                "markdown_inline",
                "query",
                "dockerfile",
                "nginx",
                "graphql",
            },
        },
        config = function(_, opts)
            require("nvim-treesitter").setup()

            -- Install parsers
            local installed = require("nvim-treesitter.config").get_installed()
            local to_install = vim.iter(opts.ensure_installed)
                :filter(function(parser) return not vim.tbl_contains(installed, parser) end)
                :totable()
            if #to_install > 0 then require("nvim-treesitter").install(to_install) end

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
        },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = { use_default_keymaps = false },
    },
}

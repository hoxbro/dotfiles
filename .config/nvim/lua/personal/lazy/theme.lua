return {
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        opts = { style = "deep", code_style = { comments = "none" } },
        init = function() vim.cmd.colorscheme("onedark") end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        priority = 999,
        opts = {
            options = {
                theme = "onedark",
                component_separators = { left = "|", right = "|" },
                section_separators = { left = nil, right = nil },
            },
            sections = {
                lualine_c = { { "filename", path = 1 } },
                lualine_x = {},
            },
        },
    },
}

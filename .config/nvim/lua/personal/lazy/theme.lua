local function file_mode_numeric()
    local file = vim.fn.expand("%:p")
    if vim.fn.filereadable(file) == 0 then return "" end
    local stat = (vim.uv or vim.loop).fs_stat(file)
    if not stat then return "" end
    return string.format("0x%03o", stat.mode % 512)
end

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
                lualine_x = { file_mode_numeric },
            },
        },
    },
}

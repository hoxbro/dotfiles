local function file_mode_numeric()
    local file = vim.fn.expand("%:p")
    if vim.fn.filereadable(file) == 0 then return "" end
    local stat = (vim.uv or vim.loop).fs_stat(file)
    if not stat then return "" end
    return string.format("0x%03o", stat.mode % 512)
end

local in_worktree = false
local function update_worktree()
    in_worktree = false
    local out = vim.fn.system({ "wt", "list", "--format=json" })
    if vim.v.shell_error ~= 0 then return end
    for _, wt in ipairs(vim.json.decode(out, { luanil = { object = true } }).items) do
        if wt.worktree and wt.worktree.current then in_worktree = not wt.worktree.main end
    end
end
update_worktree()
vim.api.nvim_create_autocmd("DirChanged", {
    group = vim.api.nvim_create_augroup("lualine-worktree", { clear = true }),
    callback = update_worktree,
})

return {
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        opts = { style = "deep", code_style = { comments = "none" } },
        init = function()
            vim.cmd.colorscheme("onedark")
            vim.api.nvim_set_hl(0, "MatchParen", { fg = "#1a212e", bg = "#efbd5d", bold = true })
        end,
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
                lualine_b = {
                    {
                        "branch",
                        icons_enabled = false,
                        fmt = function(s) return s ~= "" and ((in_worktree and "󰙅 " or "\238\130\160 ") .. s) or s end,
                        color = function() return in_worktree and "DiagnosticWarn" or {} end,
                    },
                    "diff",
                    "diagnostics",
                },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { file_mode_numeric },
            },
        },
    },
}

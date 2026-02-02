local group = vim.api.nvim_create_augroup("fold-dbout", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "dbout",
    callback = function() vim.opt_local.foldenable = false end,
})

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "sql" } },
    },
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = { "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-completion" },
        cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
        init = function() vim.g.db_ui_use_nerd_fonts = 1 end,
    },
    {
        "saghen/blink.cmp",
        ft = { "sql" },
        opts = {
            sources = {
                default = { "dadbod" },
                per_filetype = { sql = { "snippets", "dadbod", "buffer" } },
                providers = { dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" } },
            },
        },
    },
}

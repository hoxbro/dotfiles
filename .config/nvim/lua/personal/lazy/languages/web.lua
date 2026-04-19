return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "html", "css", "nginx", "graphql" } },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "css-lsp", "html-lsp" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = { cssls = {}, html = {} },
    },
}

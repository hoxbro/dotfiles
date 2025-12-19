return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "html", "css", "nginx", "graphql" } },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "html-lsp", "css-lsp" } },
    },
}

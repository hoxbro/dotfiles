return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            html = { filetypes = { "html", "twig", "hbs" } },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "html-lsp", "css-lsp" } },
    },
}

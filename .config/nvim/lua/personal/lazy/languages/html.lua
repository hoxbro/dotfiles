return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            html = { filetypes = { "html", "twig", "hbs" } },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = { html = { "html-lsp", "css-lsp" } },
    },
}

return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = "markdown",
        opts = {},
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = { markdown = { "marksman" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = { marksman = { root_markers = { ".marksman.toml", ".git" } } },
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        keys = { { "<leader>mw", "<Plug>MarkdownPreview", desc = "Markdown Preview" } },
        build = "cd app && npm install && git restore yarn.lock",
        init = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = "markdown",
    },
    {
        "folke/snacks.nvim",
        ft = "markdown",
        opts = { image = {} },
    },
    {
        "HakonHarnes/img-clip.nvim",
        ft = "markdown",
        opts = {},
        keys = { { "<leader>mp", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" } },
    },
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "markdown", "markdown_inline" } },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "marksman" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = { marksman = { root_markers = { ".marksman.toml", ".git" } } },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = "markdown",
        opts = {},
    },
    {
        "folke/snacks.nvim",
        ft = "markdown",
        opts = { image = {} },
    },
    {
        "HakonHarnes/img-clip.nvim",
        opts = {},
        keys = { { "<leader>mp", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" } },
    },
}

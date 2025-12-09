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

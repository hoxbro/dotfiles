return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "dockerfile" } },
    },
    {
        "williamboman/mason.nvim",
        opts = {
            install = {
                "docker-compose-language-service",
                "dockerfile-language-server",
                "hadolint",
            },
        },
    },
}

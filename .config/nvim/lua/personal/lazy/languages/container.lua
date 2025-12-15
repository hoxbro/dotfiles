return {
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

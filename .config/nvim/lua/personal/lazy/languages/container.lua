return {
    {
        "williamboman/mason.nvim",
        opts = {
            container = {
                "docker-compose-language-service",
                "dockerfile-language-server",
                "hadolint",
            },
        },
    },
}

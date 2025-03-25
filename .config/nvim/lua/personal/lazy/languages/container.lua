return {
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            container = {
                "docker-compose-language-service",
                "dockerfile-language-server",
                "hadolint",
            },
        },
    },
}

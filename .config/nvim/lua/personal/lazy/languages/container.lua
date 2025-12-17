vim.filetype.add({
    filename = {
        ["docker-compose.yaml"] = "yaml.docker-compose",
        ["docker-compose.yml"] = "yaml.docker-compose",
        ["compose.yaml"] = "yaml.docker-compose",
        ["compose.yml"] = "yaml.docker-compose",
    },
})

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "dockerfile" } },
    },
    {
        "williamboman/mason.nvim",
        opts = {
            install = { "docker-compose-language-service", "dockerfile-language-server" },
        },
    },
}

vim.filetype.add({
    pattern = {
        ["compose.*%.ya?ml"] = "yaml.docker-compose",
        ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
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

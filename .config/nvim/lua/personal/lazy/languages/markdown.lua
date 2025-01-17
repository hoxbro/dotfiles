return {
    {
        "neovim/nvim-lspconfig",
        opts = { marksman = {} },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = { markdown = { "marksman" } },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = "markdown",
        opts = {},
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
        "3rd/image.nvim",
        build = false,
        ft = "markdown",
        opts = {
            processor = "magick_cli",
            integrations = {
                markdown = {
                    clear_in_insert_mode = true,
                    download_remote_images = true,
                    only_render_image_at_cursor = true,
                },
            },
            editor_only_render_when_focused = false,
            tmux_show_only_in_active_window = true,
        },
    },
    --[[
    {
        "HakonHarnes/img-clip.nvim",
        ft = "markdown",
        opts = {
            dir_path = "Attachments/",
            template = "![$FILE_NAME]($FILE_PATH)",
        },
    },
    ]]
}

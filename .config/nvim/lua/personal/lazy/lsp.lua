local on_attach = function(_, bufnr)
    local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Variable")
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
    map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature Help")

    local sp = require("snacks").picker
    map("n", "gd", sp.lsp_definitions, "Goto Definition")
    map("n", "gr", sp.lsp_references, "Goto References")
    map("n", "gi", sp.lsp_implementations, "Goto Implementation")
    map("n", "<leader>gt", sp.lsp_type_definitions, "Type Definition")
    map("n", "<leader>ds", sp.lsp_symbols, "Document Symbols")
    map("n", "<leader>ws", sp.lsp_workspace_symbols, "Workspace Symbols")
end

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        dependencies = {
            { "williamboman/mason-lspconfig.nvim", dependencies = { "williamboman/mason.nvim" } },
            { "j-hui/fidget.nvim", opts = {} },
        },
        -- `opts` are a table where:
        --
        --  - Keys (`String`) are the server name.
        --  - Values (`Table`) are the settings for the lspconfig.
        config = function(_, opts)
            for server_name, config in pairs(opts) do
                vim.lsp.config(server_name, {
                    on_attach = on_attach,
                    settings = config,
                    filetypes = (config or {}).filetypes,
                    cmd = (config or {}).cmd,
                })
            end
            -- https://www.reddit.com/r/neovim/comments/1l7pz1l/starting_from_0112_i_have_a_weird_issue/
            vim.schedule(function() require("mason-lspconfig").setup() end)
        end,
    },
    {
        "jmbuhr/otter.nvim",
        keys = { { "<leader>co", function() require("otter").activate() end, desc = "Activate otter" } },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {},
    },
}

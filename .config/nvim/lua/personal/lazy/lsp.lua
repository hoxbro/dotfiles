local on_attach = function(_, bufnr)
    local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    map("n", "cr", vim.lsp.buf.rename, "Rename Variable")
    map({ "n", "x" }, "ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
    map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature Help")

    local tb = require("telescope.builtin")
    map("n", "gd", tb.lsp_definitions, "Goto Definition")
    map("n", "gr", tb.lsp_references, "Goto References")
    map("n", "gi", tb.lsp_implementations, "Goto Implementation")
    map("n", "<leader>gt", tb.lsp_type_definitions, "Type Definition")
    map("n", "<leader>ds", tb.lsp_document_symbols, "Document Symbols")
    map("n", "<leader>ws", tb.lsp_dynamic_workspace_symbols, "Workspace Symbols")
end

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
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
                })
            end
            require("mason-lspconfig").setup()
        end,
    },
}

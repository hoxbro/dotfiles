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
            -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

            -- Setup lspconfig
            local handlers = function(server_name)
                require("lspconfig")[server_name].setup({
                    capabilities = capabilities,
                    on_attach = on_attach,
                    settings = opts[server_name],
                    filetypes = (opts[server_name] or {}).filetypes,
                })
            end
            ---@diagnostic disable-next-line: missing-fields
            require("mason-lspconfig").setup({ handlers = { handlers } })
        end,
    },
}

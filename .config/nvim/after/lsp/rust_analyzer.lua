-- To not get println!(<CURSOR>) but println!
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false

---@type vim.lsp.Config
return {
    settings = {
        ["rust-analyzer"] = {
            diagnostics = { enable = false },
            checkOnSave = { enable = false },
        },
    },
    capabilities = capabilities,
}

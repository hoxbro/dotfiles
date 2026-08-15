local s = {
    preferGoToSourceDefinition = true,
    inlayHints = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
    },
}

---@type vim.lsp.Config
return {
    settings = { typescript = s, javascript = s, typescriptreact = s, javascriptreact = s },
}

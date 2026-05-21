---@type vim.lsp.Config
return {
    settings = {
        python = {
            defaultInterpreterPath = vim.fn.exepath("python"),
            pyrefly = {
                diagnosticMode = "openFilesOnly",
            },
        },
    },
}

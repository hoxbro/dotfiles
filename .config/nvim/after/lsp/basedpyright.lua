---@type vim.lsp.Config
return {
    settings = {
        python = { pythonPath = vim.fn.exepath("python") },
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                    reportUnusedParameter = false,
                },
            },
        },
    },
}

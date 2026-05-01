---@type vim.lsp.Config
return {
    on_init = function(client)
        -- Avoid overwriting code injections
        vim.api.nvim_set_hl(0, "@lsp.type.string.python", {})
    end,
    settings = {
        diagnosticMode = (vim.env.TY_CHECK and "openFilesOnly") or "off",
        configuration = {
            environment = { python = vim.fn.exepath("python") },
            rules = {
                ["unresolved-import"] = "ignore",
            },
        },
    },
}

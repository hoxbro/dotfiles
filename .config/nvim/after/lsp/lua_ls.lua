---@type vim.lsp.Config
return {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            library = { "${3rd}/luv/library", unpack(vim.api.nvim_get_runtime_file("", true)) },
            diagnostics = { globals = { "vim", "require" } },
        },
    },
}

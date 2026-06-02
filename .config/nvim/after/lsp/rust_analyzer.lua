---@type vim.lsp.Config
return {
    settings = {
        ["rust-analyzer"] = {
            diagnostics = { enable = false },
            checkOnSave = { enable = false },
            completion = {
                callable = { snippets = "none" },
            },
        },
    },
    handlers = {
        ["textDocument/completion"] = function(err, result, ctx, config)
            if result then
                local items = result.items or result
                for _, item in ipairs(type(items) == "table" and items or {}) do
                    local function strip(text) return text and text:gsub("!%b()$", "!") or text end
                    item.insertText = strip(item.insertText)
                    if item.textEdit then item.textEdit.newText = strip(item.textEdit.newText) end
                end
            end
            vim.lsp.handlers["textDocument/completion"](err, result, ctx, config)
        end,
    },
}

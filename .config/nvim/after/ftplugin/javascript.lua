vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2

-- Create an autocommand group
vim.api.nvim_create_augroup("InjectedJavascriptIndent", { clear = true })

-- Set shiftwidth=2 and tabstop=2 for JavaScript injected regions
vim.api.nvim_create_autocmd("FileType", {
    group = "InjectedJavascriptIndent",
    pattern = "javascript",
    callback = function()
        -- Only apply to injected JS, not standalone JS files
        local ok, range =
            pcall(require("vim.treesitter").get_captures_at_pos, 0, vim.fn.line(".") - 1, vim.fn.col(".") - 1)
        if not ok or not range then return end

        -- Check if this is an injected language region
        local is_injected = false
        for _, cap in ipairs(range) do
            if cap.capture == "injection.language" then
                is_injected = true
                break
            end
        end

        if is_injected then
            vim.bo.shiftwidth = 2
            vim.bo.tabstop = 2
            vim.bo.softtabstop = 2
        end
    end,
})

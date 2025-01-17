local has_words_before = function()
    if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then return false end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "onsails/lspkind.nvim",
    },
    opts = function()
        local cmp = require("cmp")
        local lspkind = require("lspkind")

        return {
            sources = {
                { name = "copilot", group_index = 2 },
                { name = "nvim_lsp", group_index = 2 },
                { name = "path", group_index = 2 },
                { name = "nvim_lsp_signature_help", group_index = 1 },
            },
            enabled = function()
                local filetype = vim.bo.filetype
                -- vim.api.nvim_buf_get_option(0, "filetype")
                return filetype ~= "prompt" or vim.startswith(filetype, "dapui_") or filetype == "dap-repl"
            end,
            mapping = {
                -- ["<CR>"] = cmp.mapping.confirm({ select = false }),
                -- ["<Tab>"] = cmp.mapping(function(fallback)
                --     if cmp.visible() and has_words_before() then
                --         cmp.select_next_item()
                --     else
                --         fallback()
                --     end
                -- end, { "i", "s" }),
                -- ["<S-Tab>"] = cmp.mapping(function(fallback)
                --     if cmp.visible() then
                --         cmp.select_prev_item()
                --     else
                --         fallback()
                --     end
                -- end, { "i", "s" }),

                -- Kickstart default
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            },
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol",
                    max_width = 50,
                    symbol_map = { Copilot = "" },
                }),
            },
        }
    end,
}

local on_attach = function(client, bufnr)
    local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Variable")
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature Help")

    local sp = require("snacks").picker
    map("n", "gd", sp.lsp_definitions, "Goto Definition")
    map("n", "gr", sp.lsp_references, "Goto References")
    map("n", "gi", sp.lsp_implementations, "Goto Implementation")
    map("n", "<leader>gt", sp.lsp_type_definitions, "Type Definition")
    map("n", "<leader>ds", sp.lsp_symbols, "Document Symbols")
    map("n", "<leader>ws", sp.lsp_workspace_symbols, "Workspace Symbols")
end

-- Not entirely sure why this is needed for lsp restart v0.12
vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("lsp-diagnostic", { clear = true }),
    callback = function(args) vim.diagnostic.reset(nil, args.buf) end,
})

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufWritePost", "BufNewFile" },
        dependencies = { { "j-hui/fidget.nvim", opts = {} } },
        opts_extend = { "enable", "attach" },
        config = function(_, opts)
            local servers = vim.list.unique(vim.list_extend(opts.attach or {}, opts.enable or {}))
            for _, server in pairs(servers) do
                vim.lsp.config(server, { on_attach = on_attach })
            end
            -- https://www.reddit.com/r/neovim/comments/1l7pz1l
            vim.schedule(function() vim.lsp.enable(opts.enable or {}) end)
        end,
    },
    {
        "jmbuhr/otter.nvim",
        keys = { { "<leader>co", function() require("otter").activate() end, desc = "Activate otter" } },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {},
    },
}

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            lua_ls = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                    library = { "${3rd}/luv/library", unpack(vim.api.nvim_get_runtime_file("", true)) },
                    diagnostics = { globals = { "vim", "require" } },
                },
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "lua-language-server" } },
    },
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            {
                "jbyuki/one-small-step-for-vimkind",
                keys = {
                    {
                        "<F8>",
                        function() require("osv").launch({ port = 8086 }) end,
                        desc = "Debug: Start Lua Server",
                    },
                },
            },
        },
        opts = function(_, opts)
            local adapters = {
                nlua = function(callback, configuration)
                    local adapter = {
                        type = "server",
                        host = configuration.host or "127.0.0.1",
                        port = configuration.port or 8086,
                    }
                    if configuration.start_neovim then
                        local dap = require("dap")
                        local dap_run = dap.run
                        ---@diagnostic disable-next-line: duplicate-set-field
                        dap.run = function(c)
                            adapter.port = c.port
                            adapter.host = c.host
                        end
                        require("osv").run_this()
                        dap.run = dap_run
                    end
                    callback(adapter)
                end,
            }
            local configurations = {
                {
                    type = "nlua",
                    request = "attach",
                    name = "Attach: Run this file",
                    start_neovim = {},
                },
                {
                    type = "nlua",
                    request = "attach",
                    name = "Attach: Running Neovim instance (F8)",
                },
            }
            opts.lua = { adapters = adapters, configurations = configurations }
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "luassert-types/library", words = { "assert" } },
                { path = "busted-types/library", words = { "describe" } },
                { path = "snacks.nvim", words = { "Snacks" } },
            },
        },
    },
    { "LuaCATS/luassert", name = "luassert-types", lazy = true },
    { "LuaCATS/busted", name = "busted-types", lazy = true },
}

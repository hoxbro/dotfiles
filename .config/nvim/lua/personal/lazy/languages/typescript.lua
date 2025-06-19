local vtsls = {
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

if DAP_typescript_commands == nil then DAP_typescript_commands = {
    "make test:unit",
} end

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            vtsls = { typescript = vtsls, javascript = vtsls },
            eslint = {},
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = { typescript = { "vtsls", "js-debug-adapter" } },
    },

    {
        "mfussenegger/nvim-dap",
        opts = function(_, opts)
            local adapter = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = { command = vim.fn.exepath("js-debug-adapter"), args = { "${port}" } },
            }
            local adapters = {
                ["pwa-node"] = adapter,
                ["pwa-chrome"] = adapter,
            }
            local configurations = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch: File",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    runtimeExecutable = "node",
                    skipFiles = { "<node_internals>/**", "**/node_modules/**" },
                    sourceMaps = true,
                    resolveSourceMapLocations = { "${workspaceFolder}/", "!/node_modules/**" },
                    console = "integratedTerminal",
                },
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch: Command",
                    cwd = "${workspaceFolder}",
                    args = function()
                        local output = Util.selector(DAP_typescript_commands, "Select an command to run:")
                        return Util.shell_split(output)
                    end,
                    runtimeExecutable = "node",
                    skipFiles = { "<node_internals>/**", "**/node_modules/**" },
                    sourceMaps = true,
                    resolveSourceMapLocations = { "${workspaceFolder}/", "!/node_modules/**" },
                    console = "integratedTerminal",
                },
                {
                    -- Run `--inspect` with the process
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach: Process (server)",
                    processId = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                    skipFiles = { "<node_internals>/**", "**/node_modules/**" },
                    sourceMaps = true,
                    resolveSourceMapLocations = { "${workspaceFolder}/", "!/node_modules/**" },
                    console = "integratedTerminal",
                },
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch: Chrome (client)",
                    url = function() return Util.input("Enter URL", "http://localhost:8000") end,
                    webRoot = vim.fs.root(0, { "tsconfig.json", "package.json", "jsconfig.json" }),
                    protocol = "inspector",
                    sourceMaps = true,
                    userDataDir = false,
                    runtimeExecutable = vim.fn.exepath("chromium"),
                },
            }
            opts.typescript = { adapters = adapters, configurations = configurations }
            opts.javascript = { configurations = configurations }
        end,
    },
}

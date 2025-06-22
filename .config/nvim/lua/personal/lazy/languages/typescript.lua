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
                        return require("dap.utils").splitstr(output)
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
                    processId = function()
                        return require("dap.utils").pick_process({
                            filter = "--inspect",
                            prompt = "Select process with --inspect",
                            label = function(proc)
                                -- Just to hide fullname of command
                                local parts = vim.split(proc.name, " ")
                                parts[1] = vim.fn.fnamemodify(parts[1], ":t")
                                local name = table.concat(parts, " ")
                                return string.format("id=%d name=%s", proc.pid, name)
                            end,
                        })
                    end,
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

local tsls = {
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
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "javascript", "typescript", "tsx" } },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "tsgo", "js-debug-adapter", "eslint-lsp" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            tsgo = { typescript = tsls, javascript = tsls, typescriptreact = tsls, javascriptreact = tsls },
            eslint = {},
        },
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
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch: Chrome (BokehJS)",
                    url = "http://127.0.0.1:5777/examples/legends",
                    webRoot = "${workspaceFolder}",
                    protocol = "inspector",
                    sourceMaps = true,
                    sourceMapPathOverrides = {
                        -- Handle the @@/ prefixed paths in bundled source maps
                        ["@@/build/js/lib/*.js"] = "${workspaceFolder}/src/lib/*.ts",
                        ["/static/js/@@/build/js/lib/*.js"] = "${workspaceFolder}/src/lib/*.ts",
                        ["static/js/@@/build/js/lib/*.js"] = "${workspaceFolder}/src/lib/*.ts",

                        -- Handle individual lib file maps
                        ["../../../src/lib/*.ts"] = "${workspaceFolder}/src/lib/*.ts",

                        -- Handle examples
                        ["../../../examples/*.ts"] = "${workspaceFolder}/examples/*.ts",
                        ["/static/examples/*.ts"] = "${workspaceFolder}/examples/*.ts",
                    },
                    userDataDir = false,
                    runtimeExecutable = vim.fn.exepath("chromium"),
                },
            }
            opts.typescript = { adapters = adapters, configurations = configurations }
            opts.javascript = { configurations = configurations }
        end,
    },
}

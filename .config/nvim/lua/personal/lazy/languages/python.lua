return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            basedpyright = {
                basedpyright = {
                    analysis = {
                        typeCheckingMode = "off",
                        autoSearchPaths = true,
                        diagnosticMode = "openFilesOnly",
                        useLibraryCodeForTypes = true,
                        diagnosticSeverityOverrides = {
                            reportUnusedParameter = false,
                        },
                    },
                },
            },
        },
    },

    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = { python = { "basedpyright" } },
    },

    {
        "mfussenegger/nvim-dap",
        opts = function(_, opts)
            local adapters = {
                python = {
                    args = { "-m", "debugpy.adapter" },
                    command = "python3",
                    options = { source_filetype = "python" },
                    type = "executable",
                },
                debugpy = {
                    type = "server",
                    host = "127.0.0.1", -- or wherever debugpy.listen is bound
                    port = 5678,
                },
            }
            local configurations = {
                {
                    name = "Launch: Panel",
                    module = "panel",
                    args = {
                        "serve",
                        "${file}",
                        "--autoreload",
                        "--unused-session-lifetime=100",
                        "--check-unused-sessions=500",
                    },
                },
                { name = "Launch: File", program = "${file}" },
                { name = "Launch: Bokeh", module = "bokeh", args = { "serve", "${file}" } },
                {
                    name = "Launch: Lumen",
                    module = "lumen",
                    args = {
                        "serve",
                        "${file}",
                        "--autoreload",
                        "--unused-session-lifetime=100",
                        "--check-unused-sessions=500",
                        "--port=5007",
                    },
                },
            }

            local defaults = {
                type = "python",
                request = "launch",
                justMyCode = "false",
                cwd = "${fileDirname}",
                console = "integratedTerminal",
            }
            for index, config in ipairs(configurations) do
                configurations[index] = vim.tbl_deep_extend("keep", config, defaults)
            end

            -- {
            --     "name": "Python Debugger: Remote Attach",
            --     "type": "debugpy",
            --     "request": "attach",
            --     "connect": {
            --         "host": "localhost",
            --         "port": 5678
            --     },
            -- }

            configurations[#configurations + 1] = {
                type = "debugpy_server",
                request = "attach",
                name = "Attach: Script", -- python -m debugpy --listen 5678 --wait-for-client filename
                -- port = 5678,
                -- host = "127.0.0.1",
                pathMappings = { { localRoot = vim.fn.getcwd(), remoteRoot = "." } },
                console = "integratedTerminal",
            }

            opts.python = { adapters = adapters, configurations = configurations }
        end,
    },
    {
        "nvim-neotest/neotest",
        dependencies = { "nvim-neotest/neotest-python" },
        opts = {
            ["neotest-python"] = {
                dap = { justMyCode = false, console = "integratedTerminal" },
                args = function(_, position)
                    local Path = require("plenary.path")
                    local elems = vim.split(position.path, Path.path.sep)
                    return (vim.tbl_contains(elems, "ui") and { "--ui" }) or {}
                end,
                is_test_file = function(file_path)
                    local Path = require("plenary.path")
                    if not vim.endswith(file_path, ".py") then return false end
                    local elems = vim.split(file_path, Path.path.sep)
                    local file_name = elems[#elems]
                    return vim.startswith(file_name, "test") and not vim.tbl_contains(elems, "node_modules")
                end,
            },
        },
    },
}

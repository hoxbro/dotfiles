local last_pid
return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            basedpyright = {
                python = { pythonPath = vim.fn.exepath("python3") or vim.fn.exepath("python") },
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
                    command = vim.fn.exepath("python3") and "python3" or "python",
                    options = { source_filetype = "python" },
                    type = "executable",
                },
                debugpy = function(callback, config)
                    last_pid = config.pid
                    local inject = config.inject
                    if not inject and Util.platform == "Linux" then
                        if vim.trim(vim.fn.system("cat /proc/sys/kernel/yama/ptrace_scope")) == "1" then
                            vim.notify("Run debugpy-inject and try again", vim.log.levels.ERROR)
                            return
                        end
                        vim.fn.system("cat /proc/" .. config.pid .. "/maps | grep -q debugpy")
                        inject = vim.v.shell_error ~= 0
                        -- TODO: on mac likely to use `vmmap pid`
                    end

                    if inject then
                        vim.fn.jobstart({
                            vim.fn.exepath("python3") and "python3" or "python",
                            "-m",
                            "debugpy",
                            "--listen",
                            config.host .. ":" .. config.port,
                            "--pid",
                            tostring(config.pid),
                        })
                    end
                    callback({ type = "server", host = config.host, port = config.port })
                end,
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

            configurations[#configurations + 1] = {
                type = "debugpy",
                request = "attach",
                name = "Attach: Process",
                pid = function()
                    local options = { "Panel App :5006", "Select a Process" }
                    if last_pid then table.insert(options, 1, "Last Process") end

                    local actions = {
                        ["Last Process"] = function() return last_pid end,
                        ["Panel App :5006"] = function()
                            return vim.trim(vim.fn.system("lsof -i :5006 -sTCP:LISTEN -t"))
                        end,
                        ["Select a Process"] = function()
                            return require("dap.utils").pick_process({ filter = "python" })
                        end,
                    }

                    local option = Util.selector(options, "Select method", "Manual")
                    local action = actions[option]
                    return action and action() or vim.trim(option)
                end,
                port = 5678,
                host = "127.0.0.1",
                inject = true,
                pathMappings = { { localRoot = vim.fn.getcwd(), remoteRoot = vim.fn.getcwd() } },
                justMyCode = "false",
            }
            configurations[#configurations + 1] = {
                type = "debugpy",
                request = "attach",
                name = "Attach: Waiting",
                pid = function() return vim.trim(vim.fn.system("lsof -i :5678 -sTCP:LISTEN -t")) end,
                port = 5678,
                host = "127.0.0.1",
                inject = false,
                pathMappings = { { localRoot = vim.fn.getcwd(), remoteRoot = vim.fn.getcwd() } },
                justMyCode = "false",
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

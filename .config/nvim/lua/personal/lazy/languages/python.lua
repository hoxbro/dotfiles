local last_pid
local python_exe = vim.fn.exepath("python3") or vim.fn.exepath("python")
return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            basedpyright = {
                python = { pythonPath = python_exe },
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
                    command = python_exe,
                    options = { source_filetype = "python" },
                    type = "executable",
                },
                ["python-attach"] = function(callback, config)
                    if config.pid == "" then return end
                    last_pid = config.pid
                    local inject = config.inject
                    if inject and Util.platform == "Linux" then
                        if vim.trim(vim.fn.system("cat /proc/sys/kernel/yama/ptrace_scope")) == "1" then
                            vim.notify("Run `pdb inject` and try again", vim.log.levels.ERROR)
                            return
                        end
                        vim.fn.system("cat /proc/" .. config.pid .. "/maps | grep -q debugpy")
                        inject = vim.v.shell_error ~= 0
                        -- TODO: on mac likely to use `vmmap pid`
                    end

                    if inject then
                        local output = vim.fn.system({
                            python_exe,
                            "-m",
                            "debugpy",
                            "--listen",
                            config.host .. ":" .. config.port,
                            "--pid",
                            tostring(config.pid),
                        })
                        if vim.v.shell_error ~= 0 then
                            vim.notify("Injection failed: " .. output, vim.log.levels.ERROR)
                            return
                        end
                    end
                    callback({ type = "server", host = config.host, port = config.port })
                end,
            }
            local launch_config = {
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

            local launch_default = {
                type = "python",
                request = "launch",
                justMyCode = "false",
                cwd = "${fileDirname}",
                console = "integratedTerminal",
            }

            local attach_config = {
                {
                    name = "Attach: Process",
                    inject = true,
                    pid = function()
                        local options = { "Panel App :5006", "Select a Process" }
                        if last_pid then table.insert(options, 1, "Last Process") end

                        local actions = {
                            ["Last Process"] = function() return last_pid end,
                            ["Panel App :5006"] = function()
                                local pid = vim.fn.system("lsof -i :5006 -sTCP:LISTEN -t")
                                if vim.v.shell_error ~= 0 then
                                    vim.notify("No PID for port 5006", vim.log.levels.ERROR)
                                end
                                return vim.trim(pid)
                            end,
                            ["Select a Process"] = function()
                                return require("dap.utils").pick_process({ filter = "python" })
                            end,
                        }

                        local option = Util.selector(options, "Select method", "Manual")
                        local action = actions[option]
                        return action and action() or vim.trim(option)
                    end,
                },
                {
                    name = "Attach: Waiting",
                    inject = false,
                    pid = function() return vim.trim(vim.fn.system("lsof -i :5678 -sTCP:LISTEN -t")) end,
                },
            }
            local attach_default = {
                type = "python-attach",
                request = "attach",
                port = 5678,
                host = "127.0.0.1",
                pathMappings = { { localRoot = vim.fn.getcwd(), remoteRoot = vim.fn.getcwd() } },
                justMyCode = "false",
            }

            -- Merge configurations
            local configurations = {}
            for _, config in ipairs(launch_config) do
                table.insert(configurations, vim.tbl_deep_extend("keep", config, launch_default))
            end
            for _, config in ipairs(attach_config) do
                table.insert(configurations, vim.tbl_deep_extend("keep", config, attach_default))
            end
            opts.python = { adapters = adapters, configurations = configurations }
        end,
    },
    {
        "nvim-neotest/neotest",
        dependencies = { "nvim-neotest/neotest-python" },
        opts = {
            ["neotest-python"] = {
                dap = { justMyCode = false, console = "integratedTerminal" },
                python = python_exe,
                -- pytest_discover_instances = true,
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

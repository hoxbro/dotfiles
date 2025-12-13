return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            bashls = { bashIde = { shellcheckArguments = "--exclude=SC1091,SC2181" } },
        },
    },

    {
        "williamboman/mason.nvim",
        opts = { bash = { "bash-language-server", "bash-debug-adapter" } },
    },

    {
        "mfussenegger/nvim-dap",
        opts = function(_, opts)
            local bash_dir = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir"
            local adapters = {
                bashdb = {
                    type = "executable",
                    command = vim.fn.exepath("bash-debug-adapter"),
                    name = "bashdb",
                },
            }
            local configurations = {
                {
                    type = "bashdb",
                    request = "launch",
                    name = "Launch: File",
                    showDebugOutput = true,
                    pathBashdb = bash_dir .. "/bashdb",
                    pathBashdbLib = bash_dir,
                    trace = true,
                    file = "${file}",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    pathCat = "cat",
                    pathBash = "bash",
                    pathMkfifo = "mkfifo",
                    pathPkill = "pkill",
                    args = {},
                    env = {},
                    terminalKind = "integrated",
                },
            }

            opts.bash = { adapters = adapters, configurations = configurations }
            opts.sh = { configurations = configurations }
        end,
    },
}

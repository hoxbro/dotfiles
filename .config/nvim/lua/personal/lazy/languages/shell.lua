vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    pattern = "*.sh",
    group = vim.api.nvim_create_augroup("shebang-env", { clear = true }),
    callback = function(args)
        local ns = vim.api.nvim_create_namespace("shebang-env")
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)
        local first = lines[1] or ""
        local shell = first:match("^#!/usr/bin/env%s+(%S+)$")
        if not (shell == "sh" or shell == "bash" or shell == "zsh") then
            vim.diagnostic.set(ns, args.buf, {
                {
                    lnum = 0,
                    col = 0,
                    message = "Shebang should use #!/usr/bin/env sh|bash|zsh",
                    severity = vim.diagnostic.severity.WARN,
                },
            }, {})
        else
            vim.diagnostic.set(ns, args.buf, {}, {})
        end
    end,
})

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "bash", "zsh" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            bashls = { bashIde = { shellcheckArguments = "--exclude=SC1091,SC2181" } },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "bash-language-server", "bash-debug-adapter", "shellcheck" } },
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

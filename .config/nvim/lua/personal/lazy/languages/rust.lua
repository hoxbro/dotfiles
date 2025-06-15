return {
    {
        "neovim/nvim-lspconfig",
        opts = { rust_analyzer = {} },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = { rust = { "codelldb", "rust_analyzer" } },
    },
    {
        "mfussenegger/nvim-dap",
        opts = function(_, opts)
            local cmds = {
                BIN = "cargo build -q --message-format=json",
                TEST = "cargo build --tests -q --message-format=json",
            }
            local function run_build(cmd)
                local function inner_build()
                    local output = vim.fn.system("cd " .. vim.fs.root(0, { "Cargo.toml" }) .. " && " .. cmd)
                    local filename = output:match('"executable":"(.-)".-"success":true}')
                    if not filename then return error("failed to build cargo project") end
                    return filename
                end
                return inner_build
            end
            local adapters = {
                codelldb = {
                    type = "server",
                    port = "${port}",
                    executable = {
                        command = vim.fn.exepath("codelldb"),
                        args = { "--port", "${port}" },
                        detached = vim.fn.has("win32") == 1,
                    },
                    name = "codelldb",
                },
            }
            local configurations = {
                {
                    name = "Launch: Binary",
                    type = "codelldb",
                    request = "launch",
                    program = run_build(cmds.BIN),
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    showDisassembly = "never",
                },
                {
                    name = "Launch: Binary w. args",
                    type = "codelldb",
                    request = "launch",
                    args = function() vim.fn.input("Arguments: ") end,
                    program = run_build(cmds.BIN),
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    showDisassembly = "never",
                },
                {
                    name = "Launch: Test",
                    type = "codelldb",
                    request = "launch",
                    program = run_build(cmds.TEST),
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    showDisassembly = "never",
                },
            }

            opts.rust = { adapters = adapters, configurations = configurations }
        end,
    },
    {
        "nvim-neotest/neotest",
        dependencies = { "rouge8/neotest-rust" },
        opts = { ["neotest-rust"] = {} },
    },
}

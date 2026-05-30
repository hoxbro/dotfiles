return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "rust" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = { enable = { "rust_analyzer", "bacon_ls" } },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "codelldb", "rust-analyzer", "bacon", "bacon-ls" } },
    },
    {
        "mfussenegger/nvim-dap",
        opts = function(_, opts)
            local cmds = {
                BIN = { "cargo", "build", "-q", "--message-format=json" },
                TEST = { "cargo", "build", "--tests", "-q", "--message-format=json" },
            }
            local function run_build(cmd)
                local function inner_build()
                    local result = vim.system(cmd, { cwd = vim.fs.root(0, { "Cargo.toml" }), text = true }):wait()
                    if result.code ~= 0 then return error("failed to build cargo project") end
                    for line in vim.gsplit(result.stdout or "", "\n") do
                        local data = vim.json.decode(line)
                        if data.executable then return data.executable end
                    end
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
                    args = function()
                        local output = Util.input("Arguments")
                        return require("dap.utils").splitstr(output)
                    end,
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
        dependencies = { "hoxbro/neotest-rust" },
        opts = { ["neotest-rust"] = {} },
    },
}

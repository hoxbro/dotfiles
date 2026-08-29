local function _bokehjs_dir()
    local cwd = vim.fn.getcwd()
    if cwd:match("/bokehjs$") ~= nil then return cwd end
    if vim.fn.isdirectory(cwd .. "/bokehjs") == 1 then return cwd .. "/bokehjs" end
    return cwd
end

local function _bokehjs()
    local bokehjs_dir = _bokehjs_dir()

    local bokehjs_source_map = {
        ["@@/*"] = bokehjs_dir .. "/*",
        ["../../../examples/*.ts"] = bokehjs_dir .. "/examples/*.ts",
    }

    for _, marker in ipairs(vim.fn.glob(vim.fn.getcwd() .. "/*/bokeh.ext.json", false, true)) do
        local ext = vim.fn.fnamemodify(marker, ":h")
        local name = vim.fn.fnamemodify(ext, ":t")
        bokehjs_source_map["@@/" .. name .. "/*"] = ext .. "/*"
    end
    return bokehjs_dir, bokehjs_source_map
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = { install = { "javascript", "typescript", "tsx" } },
    },
    {
        "williamboman/mason.nvim",
        opts = { install = { "tsc", "js-debug-adapter", "eslint-lsp" } },
    },
    {
        "neovim/nvim-lspconfig",
        opts = { enable = { "tsc", "eslint" } },
    },
    {
        "mfussenegger/nvim-dap",
        opts = function(_, opts)
            local adapter = {
                type = "server",
                host = "127.0.0.1",
                port = "${port}",
                executable = {
                    command = vim.fn.exepath("js-debug-adapter"),
                    args = { "${port}", "127.0.0.1" },
                },
            }
            local adapters = {
                ["pwa-node"] = adapter,
                ["pwa-chrome"] = adapter,
            }

            local bk_dir, bk_map = _bokehjs()
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
                        local output = Util.input("Select an command to run:")
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
                    name = "Launch: Chrome (Bokeh URL)",
                    url = function() return Util.input("Enter URL", "http://localhost:5006/") end,
                    webRoot = bk_dir,
                    protocol = "inspector",
                    sourceMaps = true,
                    sourceMapPathOverrides = bk_map,
                    userDataDir = false,
                    runtimeExecutable = vim.fn.exepath("chromium"),
                },
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch: Chrome (Bokeh file)",
                    file = function()
                        local files = vim.fn.glob(vim.fn.getcwd() .. "/*.html", false, true)
                        return Util.selector(files, "Select an html file:")
                    end,
                    webRoot = "${workspaceFolder}",
                    protocol = "inspector",
                    sourceMaps = true,
                    sourceMapPathOverrides = bk_map,
                    userDataDir = false,
                    runtimeExecutable = vim.fn.exepath("chromium"),
                },
            }
            opts.typescript = { adapters = adapters, configurations = configurations }
            opts.javascript = { configurations = configurations }
        end,
    },
}

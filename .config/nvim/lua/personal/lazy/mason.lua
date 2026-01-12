local M = {}

M.lockfile_path = vim.fn.stdpath("config") .. "/mason-lock.json"
M.pending_installs = 0
M.setup_started = false

function M.read_lockfile()
    local file = io.open(M.lockfile_path, "r")
    if not file then return {} end
    local content = file:read("*all")
    file:close()
    return vim.json.decode(content) or {}
end

function M.write_lockfile(data)
    local file = io.open(M.lockfile_path, "w")
    if not file then
        vim.notify("Failed to write lockfile", vim.log.levels.ERROR)
        return
    end

    -- Format table
    local sorted_keys = vim.tbl_keys(data)
    table.sort(sorted_keys, function(a, b) return a:lower() < b:lower() end)
    local lines = { "{" }
    for i, key in ipairs(sorted_keys) do
        local value = data[key]
        local comma = i < #sorted_keys and "," or ""
        table.insert(lines, string.format('  "%s": "%s"%s', key, value, comma))
    end
    table.insert(lines, "}")

    file:write(table.concat(lines, "\n") .. "\n")
    file:close()
end

function M.get_installed_packages()
    local registry = require("mason-registry")
    local packages = {}
    for _, pkg in ipairs(registry.get_installed_packages()) do
        if pkg:is_installed() then packages[pkg.name] = pkg:get_installed_version() end
    end
    return packages
end

function M.ensure_installed(pkg_name, locked_version)
    local registry = require("mason-registry")
    local ok, pkg = pcall(registry.get_package, pkg_name)

    if not ok then
        local mappings = require("mason-lspconfig").get_mappings()
        local lsp_pkg_name = mappings.lspconfig_to_package[pkg_name] or pkg_name
        if lsp_pkg_name ~= pkg_name then
            vim.notify(string.format("Used LSP mapping: %s -> %s", pkg_name, lsp_pkg_name))
            ok, pkg = pcall(registry.get_package, lsp_pkg_name)
        end
    end

    if not ok then
        vim.notify(string.format("Package '%s' not found in registry", pkg_name), vim.log.levels.WARN)
        return
    end

    if pkg:is_installed() then
        local installed_version = pkg:get_installed_version()
        if locked_version and installed_version ~= locked_version then
            vim.notify(string.format("Updating %s: %s -> %s", pkg_name, installed_version, locked_version))
            pkg:install({ version = locked_version })
        end
        return
    end

    local version_str = locked_version and ("@" .. locked_version) or ""
    vim.notify(string.format("Installing %s%s", pkg_name, version_str))

    M.pending_installs = M.pending_installs + 1
    if locked_version then
        pkg:install({ version = locked_version })
    else
        pkg:install()
    end
end

function M.setup(opts)
    local registry = require("mason-registry")
    local lockfile = M.read_lockfile()

    registry:on("package:install:success", function()
        M.pending_installs = M.pending_installs - 1
        local packages = M.get_installed_packages()
        M.write_lockfile(packages)
    end)

    registry:on("package:uninstall:success", function()
        local packages = M.get_installed_packages()
        M.write_lockfile(packages)
    end)

    registry.refresh(function()
        M.setup_started = true
        local should_keep = vim.tbl_keys(lockfile)
        for _, pkg_name in ipairs(Util.unique(opts.install or {})) do
            M.ensure_installed(pkg_name, lockfile[pkg_name])
            table.insert(should_keep, pkg_name)
        end

        for _, pkg in ipairs(registry.get_installed_packages()) do
            if not vim.tbl_contains(should_keep, pkg.name) then
                vim.notify(string.format("Uninstalling %s", pkg.name))
                pkg:uninstall()
            end
        end
    end)
end

vim.api.nvim_create_user_command("MasonSetup", function()
    require("mason")
    vim.wait(600000, function() return M.setup_started and M.pending_installs == 0 end, 1000, false)
end, { desc = "Wait for all Mason package installations to complete" })

return {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    opts_extend = { "install" },
    config = function(_, opts)
        require("mason").setup()
        vim.schedule(function() M.setup(opts) end)
    end,
}

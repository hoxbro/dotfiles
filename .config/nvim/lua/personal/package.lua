local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.o.rtp = lazypath .. "," .. vim.o.rtp

require("lazy").setup({
    spec = { { import = "personal.lazy" }, { import = "personal.lazy.languages" } },
    change_detection = { notify = false },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "rplugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

vim.schedule(function()
    local Config = require("lazy.core.config")
    local Lock = require("lazy.manage.lock")
    local Git = require("lazy.manage.git")
    local lazy = require("lazy")

    -- Check if any plugins need restoring
    Lock.load()
    local needs_restore = {}
    for _, plugin in pairs(Config.plugins) do
        if not plugin._.is_local and plugin._.installed then
            local lock_info = Lock.get(plugin)
            if lock_info then
                local current_info = Git.info(plugin.dir)
                if current_info and current_info.commit ~= lock_info.commit then
                    table.insert(needs_restore, plugin.name)
                end
            end
        end
    end

    local function do_clean()
        if Config.to_clean and #Config.to_clean > 0 then
            local to_clean = {}
            for _, plugin in ipairs(Config.to_clean) do
                table.insert(to_clean, plugin.name)
            end
            print("lazy[remove]: " .. table.concat(to_clean, ", "))
            lazy.clean({ wait = false, show = false })
        end
    end

    if #needs_restore > 0 then
        lazy.restore({ wait = false, show = false }):wait(function()
            print("lazy[restore]: " .. table.concat(needs_restore, ", "))
            do_clean()
        end)
    else
        do_clean()
    end
end)

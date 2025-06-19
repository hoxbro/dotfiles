return {
    { "williamboman/mason.nvim", lazy = true, opts = {}, cmd = "MasonUpdate" },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = "williamboman/mason.nvim",
        event = "VeryLazy",
        cmd = { "MasonToolsUpdate", "MasonToolsInstall", "MasonToolsUpdateSync", "MasonToolsInstallSync" },
        -- `opts` are a table where:
        --
        --  - Keys (`String`) unique name, which will be discarded.
        --  - Values (`List`) the packages which needs to `ensure_installed`
        config = function(_, opts)
            -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/37
            local mst = require("mason-tool-installer")
            local ensure_installed = vim.iter(vim.tbl_values(opts)):flatten():totable()
            mst.setup({ ensure_installed = ensure_installed })
            mst.run_on_start()
        end,
    },
}

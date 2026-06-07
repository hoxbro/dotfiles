---@type vim.lsp.Config
return {
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname:find(vim.env.HOME .. "/.rustup", 1, true) then return end
        return on_dir(vim.fs.root(bufnr, { ".bacon-locations", "Cargo.toml" }))
    end,
    settings = {
        bacon_ls = {
            cargo = { command = "clippy" },
        },
    },
}

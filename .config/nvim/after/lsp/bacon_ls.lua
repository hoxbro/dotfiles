return {
    root_dir = function(bufnr)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname:find(vim.env.HOME .. "/.rustup", 1, true) then return nil end
        return vim.fs.root(bufnr, { ".bacon-locations", "Cargo.toml" })
    end,
}

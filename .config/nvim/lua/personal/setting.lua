vim.g.mapleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true
vim.opt.writebackup = false

vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.showmode = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.diagnostic.config({
    signs = { severity = { min = vim.diagnostic.severity.INFO } },
    virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
})
vim.treesitter.language.register("python", "pyodide")

vim.opt.formatoptions:append({ c = true, r = true, q = true })

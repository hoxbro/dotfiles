vim.o.nu = true
vim.o.relativenumber = true

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.wrap = false
vim.o.linebreak = true

vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.o.undofile = true
vim.o.writebackup = false
vim.o.shadafile = vim.fn.stdpath("data") .. "/shada/" .. vim.fn.getcwd():gsub("[/\\:]", "%%")

vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.isfname = vim.o.isfname .. ",@-@"

vim.o.incsearch = true
vim.o.termguicolors = true
vim.o.updatetime = 50

vim.o.showmode = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.iskeyword = vim.o.iskeyword .. ",-"
vim.o.formatoptions = vim.o.formatoptions .. "q"

vim.o.fillchars = "diff:╱"
vim.o.diffopt = "internal,filler,closeoff,context:12,algorithm:histogram,linematch:200,indent-heuristic"

vim.diagnostic.config({
    signs = {
        severity = { min = vim.diagnostic.severity.INFO },
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    },
    virtual_text = { severity = { min = vim.diagnostic.severity.WARN } },
})
vim.treesitter.language.register("python", "pyodide")

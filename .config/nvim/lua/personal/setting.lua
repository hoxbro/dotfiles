vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.linebreak = true

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
vim.opt.iskeyword:append("-")

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

vim.opt.formatoptions:append({ c = true, r = true, q = true })

vim.opt.fillchars = { diff = "╱" }
vim.opt.diffopt = {
    "internal",
    "filler",
    "closeoff",
    "context:12",
    "algorithm:histogram",
    "linematch:200",
    "indent-heuristic",
}

-- Jump list per path
local function get_shada_path()
    local cwd = vim.fn.getcwd()
    local safe_path = cwd:gsub("/", "%%"):gsub(":", "%%")
    return vim.fn.stdpath("data") .. "/shada/" .. safe_path .. ".shada"
end
vim.fn.mkdir(vim.fn.stdpath("data") .. "/shada", "p")
vim.opt.shadafile = get_shada_path()

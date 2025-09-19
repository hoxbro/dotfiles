-- Global settings
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit Insert Mode" })
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-V>", "<C-v>", { desc = "V-Block Mode" })

-- Better movement
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Go Down A Line" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Go Up A Line" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join Lines" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Get Previous Search Item" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Get Next Search Item" })
vim.keymap.set("v", "<", "<gv", { desc = "Keep Visual After Dedent" })
vim.keymap.set("v", ">", ">gv", { desc = "Keep Visual After Indent" })
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Go To Next Quickfix Item" })
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Go To Previous Quickfix Item" })

-- Bypassing the yank register and clipboard support
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
vim.keymap.set("n", "<leader>D", [["_D]], { desc = "Delete without yanking" })
vim.keymap.set("n", "<leader>c", [["_c]], { desc = "Change without yanking]" })
vim.keymap.set("i", "<A-v>", "<C-r>0", { desc = "Paste in insertmode", noremap = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set(
    "n",
    "[d",
    function() vim.diagnostic.jump({ count = -1, float = true }) end,
    { desc = "Go To Previous Diagnostic Message" }
)
vim.keymap.set(
    "n",
    "]d",
    function() vim.diagnostic.jump({ count = 1, float = true }) end,
    { desc = "Go To Next Diagnostic Message" }
)
vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { desc = "Show Diagnostic Error Messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open Diagnostic Quickfix List" })

-- Replace keymaps
local function get_replace_config()
    if vim.bo.buftype == "quickfix" then
        return "cdo s/", "/gc"
    else
        return "%s/", "/gI"
    end
end

local function get_visual_pattern()
    local _, ls, cs = unpack(vim.fn.getpos("v"))
    local _, le, ce = unpack(vim.fn.getpos("."))
    if cs == ce and le == ls then -- v-line
        local line = vim.api.nvim_get_current_line()
        ce = string.len(line)
        cs = string.find(line, "%S") or ce
    end
    if cs == ce then return nil end
    if ls > le or (ls == le and cs > ce) then
        ls, le, cs, ce = le, ls, ce, cs
    end
    local pattern = table.concat(vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {}))
    return vim.fn.substitute(vim.fn.escape(pattern, "^$.*\\/~[]"), "\n", "\\n", "g")
end

vim.keymap.set("n", "<leader>r", function()
    local pattern = vim.fn.expand("<cword>")
    local cmd, flags = get_replace_config()
    vim.api.nvim_input("<Esc>:" .. cmd .. pattern .. "/" .. pattern .. flags .. string.rep("<Left>", #flags))
end, { desc = "Find And Replace Word" })

vim.keymap.set("v", "<leader>r", function()
    local pattern = get_visual_pattern()
    if not pattern then return end
    local cmd, flags = get_replace_config()
    vim.api.nvim_input("<Esc>:" .. cmd .. pattern .. "/" .. pattern .. flags .. string.rep("<Left>", #flags))
end, { desc = "Find And Replace Highlighted Text" })

-- Inlay Hints
vim.keymap.set(
    "n",
    "<leader>ch",
    function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
    { desc = "Inlay Hints" }
)
vim.keymap.set("n", "<leader>ci", require("personal.util.virtual_text").virtual_to_inline_text)

-- Advanced keymaps
vim.keymap.set(
    "n",
    "<leader>x",
    '<cmd>silent ![ -x "%" ] && chmod u-x "%" || chmod u+x "%"<CR>',
    { desc = "Toggle Executable Bit" }
)

vim.keymap.set("n", "<leader>tw", function() vim.wo.wrap = not vim.wo.wrap end, { desc = "Toggle text wrap" })

-- Here because of muscle memory
local ny = function() vim.notify("just use normal yank") end
vim.keymap.set("v", "<leader>y", ny)
vim.keymap.set("n", "<leader>Y", ny)
vim.keymap.set("n", "<Leader>y", ny)

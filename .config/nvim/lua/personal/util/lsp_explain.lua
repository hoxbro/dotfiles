-- Explain diagnostic rule in a hover float
local tools = {
    ruff = { "rule" },
    ty = { "explain", "rule" },
}

local explain_open_float = function(cmd, subcmd, rule)
    local args = vim.list_extend({ vim.fn.exepath(cmd) }, subcmd)
    table.insert(args, rule)
    local output = vim.fn.systemlist(args)
    if vim.v.shell_error ~= 0 or #output == 0 then
        vim.notify(cmd .. " " .. table.concat(subcmd, " ") .. " " .. rule .. " failed", vim.log.levels.ERROR)
        return
    end
    local _, winid = vim.lsp.util.open_floating_preview(output, "markdown", {
        border = "rounded",
        title = " " .. cmd .. " " .. rule .. " ",
        title_pos = "center",
        max_width = 80,
        max_height = 30,
        focus = true,
    })
    vim.api.nvim_set_current_win(winid)
end

local explain = function()
    local lnum = vim.fn.line(".") - 1
    local diagnostics = vim.diagnostic.get(0, { lnum = lnum })

    local rules = {}
    local seen = {}
    for _, d in ipairs(diagnostics) do
        local source = d.source and d.source:lower()
        if source and tools[source] and d.code and not seen[source .. d.code] then
            seen[source .. d.code] = true
            table.insert(rules, { tool = source, code = d.code, message = d.message })
        end
    end

    if #rules == 0 then
        vim.notify("No explainable diagnostic found on current line", vim.log.levels.WARN)
    elseif #rules == 1 then
        explain_open_float(rules[1].tool, tools[rules[1].tool], rules[1].code)
    else
        vim.ui.select(rules, {
            prompt = "Explain rule:",
            format_item = function(item) return "[" .. item.tool .. "] " .. item.code .. ": " .. item.message end,
        }, function(choice)
            if choice then explain_open_float(choice.tool, tools[choice.tool], choice.code) end
        end)
    end
end

vim.keymap.set("n", "<leader>ce", explain, { desc = "Explain LSP Diagnostic Rule" })

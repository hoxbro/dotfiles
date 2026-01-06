local M = {}

local REGISTERS = {
    '"',
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
}

function M.new() return setmetatable({}, { __index = M }) end

function M:get_completions(_, callback)
    local items = {}
    for idx, reg in ipairs(REGISTERS) do
        local val = vim.fn.getreg(reg)
        if val ~= "" and not val:match("^%s*$") then
            table.insert(items, {
                label = "  " .. val:gsub("^%s+", ""):gsub("\n", " "):sub(1, 20),
                insertText = val,
                score_offset = 1000 - idx,
                documentation = { kind = "markdown", value = "```\n" .. val .. "\n```" },
            })
        end
    end
    callback({ items = items, is_incomplete = false })
end

return M

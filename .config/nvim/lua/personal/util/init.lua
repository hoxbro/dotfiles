require("personal.util.autocmd")
require("personal.util.virtual_text")
require("personal.util.yankring")

Util = {}

Util.get_root = function(patterns)
    patterns = type(patterns) == "string" and { patterns } or patterns
    local path = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    local pattern = vim.fs.find(function(name)
        for _, p in ipairs(patterns) do
            if name == p then return true end
            if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then return true end
        end
        return false
    end, { path = path, upward = true })[1]
    return vim.fs.dirname(pattern)
end

Util.selector = function(options, title)
    local action_state = require("telescope.actions.state")
    local actions = require("telescope.actions")
    local finders = require("telescope.finders")
    local pickers = require("telescope.pickers")
    local themes = require("telescope.themes")

    local co = coroutine.running()

    pickers
        .new(
            themes.get_dropdown({
                prompt_title = title or "Select an Option",
                previewer = false,
            }),
            {
                finder = finders.new_table(options),
                sorter = require("telescope.config").values.generic_sorter({}),
                attach_mappings = function(prompt_bufnr)
                    local state = true
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        if selection == nil then
                            selection = action_state.get_current_line()
                            local picker = action_state.get_current_picker(prompt_bufnr)

                            table.insert(options, selection)
                            picker:refresh(finders.new_table(options), { reset_prompt = false })
                            state = false
                        else
                            actions.close(prompt_bufnr)
                            coroutine.resume(co, selection[1])
                        end
                    end)
                    return state
                end,
            }
        )
        :find()

    return coroutine.yield()
end

Util.shell_split = function(command)
    local result = {}
    local current = ""
    local in_quotes = nil
    local escape = false

    for i = 1, #command do
        local c = command:sub(i, i)
        if escape then
            current = current .. c
            escape = false
        elseif c == "\\" then
            escape = true
        elseif c == '"' or c == "'" then
            if in_quotes == c then
                in_quotes = nil
            elseif not in_quotes then
                in_quotes = c
            else
                current = current .. c
            end
        elseif c:match("%s") then
            if not in_quotes then
                if #current > 0 then
                    table.insert(result, current)
                    current = ""
                end
            else
                current = current .. c
            end
        else
            current = current .. c
        end
    end

    if #current > 0 then table.insert(result, current) end
    return result
end

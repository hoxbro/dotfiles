require("personal.util.autocmd")
require("personal.util.virtual_text")
require("personal.util.yankring")

Util = {}

Util.selector = function(options, prompt, custom_input)
    local co = coroutine.running()
    local choices = options

    if custom_input == nil then custom_input = "Custom..." end
    if custom_input then
        choices = vim.deepcopy(choices)
        table.insert(choices, custom_input)
    end

    vim.ui.select(choices, { prompt = prompt }, function(choice)
        if custom_input and choice == custom_input then
            vim.ui.input({ prompt = "Enter custom choice" }, function(custom)
                table.insert(options, custom)
                coroutine.resume(co, custom)
            end)
        elseif choice then
            coroutine.resume(co, choice)
        end
    end)

    return coroutine.yield()
end

Util.input = function(prompt, default)
    local co = coroutine.running()
    vim.ui.input({ prompt = prompt, default = default }, function(result) coroutine.resume(co, result) end)
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

local _platform = function()
    if vim.fn.has("win32") == 1 then
        return "Windows"
    elseif vim.fn.has("macunix") == 1 then
        return "macOS"
    elseif vim.fn.has("unix") == 1 then
        return "Linux"
    else
        return "Unknown"
    end
end

setmetatable(Util, {
    __index = function(t, key)
        if key == "platform" then
            local platform = _platform()
            rawset(t, key, platform)
            return platform
        end
    end,
})

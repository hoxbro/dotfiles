-- Setup nvim
local setup = function()
    vim.notify("Setting up nvim", vim.log.levels.INFO)

    vim.cmd("Lazy! restore")
    vim.notify("✓ Lazy restore complete", vim.log.levels.INFO)

    vim.cmd("MasonSetup")
    vim.notify("✓ MasonSetup complete", vim.log.levels.INFO)

    vim.cmd("BlinkDownload")
    vim.notify("✓ BlinkDownload complete", vim.log.levels.INFO)

    vim.notify("All setup commands completed!", vim.log.levels.INFO)
end
vim.api.nvim_create_user_command("Setup", setup, { desc = "Run all setup commands" })

-- Ruff to quicklist
local astral_quicklist = function(command, opts)
    local path = opts.args
    if not path or path == "" then path = vim.fn.getcwd() end

    local output = vim.fn.systemlist({
        vim.fn.exepath(command),
        "check",
        "--exit-zero",
        "--exclude",
        "*.ipynb",
        "--output-format",
        "concise",
        path,
    })

    if vim.fn.match(output[1] or "", "All checks passed!") ~= -1 then
        -- Just print the output if all checks passed
        print(table.concat(output, "\n"))
    else
        -- Load output into quickfix list
        local qf_entries = {}
        for _, line in ipairs(output) do
            local filename, lnum, col, text = line:match("^(.-):(%d+):(%d+):%s*(.*)")
            if filename then
                table.insert(qf_entries, {
                    filename = filename,
                    lnum = tonumber(lnum),
                    col = tonumber(col),
                    text = text,
                })
            end
        end
        vim.fn.setqflist({}, " ", { title = "Ruff", items = qf_entries })
        vim.cmd("copen")
        vim.cmd("cfirst")
    end
end

vim.api.nvim_create_user_command("RuffQuickfix", function(opts) astral_quicklist("ruff", opts) end, {
    nargs = "?",
    complete = "file",
})

vim.api.nvim_create_user_command("TyQuickfix", function(opts) astral_quicklist("ty", opts) end, {
    nargs = "?",
    complete = "file",
})

-- Pytest failing tests to quickfix (with line + column detection)
local pytest_quicklist = function()
    local file = "failing_tests.txt"
    if vim.fn.filereadable(file) == 0 then
        print("File not found: " .. file)
        return
    end

    local lines = vim.fn.readfile(file)
    if #lines == 0 then
        print("No failing tests found in " .. file)
        return
    end

    local qf_entries = {}

    for _, line in ipairs(lines) do
        if not line or line == "" then
            -- skip empty lines
        else
            -- Split at the LAST :: to isolate test_raw (greedy .* ensures it's the last)
            local prefix, test_raw = line:match("^(.*)::([^:]+)$")
            if prefix and test_raw then
                -- Strip trailing [params] if present
                local testname = test_raw:gsub("%b[]$", "")

                -- From prefix, optionally split filename and class (again split at last ::)
                local filename, _ = prefix:match("^(.*)::([^:]+)$")
                if not filename then filename = prefix end

                if filename and testname and filename ~= "" and testname ~= "" then
                    local lnum, col = 1, 1
                    if vim.fn.filereadable(filename) == 1 then
                        local content = vim.fn.readfile(filename)
                        for i, l in ipairs(content) do
                            if l:match("def%s+" .. vim.pesc(testname) .. "%s*%(") then
                                lnum = i
                                local _, cstart = l:find("^%s*")
                                col = (cstart or 0) + 1
                                break
                            end
                        end
                    end

                    table.insert(qf_entries, {
                        filename = filename,
                        lnum = lnum,
                        col = col,
                        text = line,
                    })
                end
            end
        end
    end

    vim.fn.setqflist({}, " ", { title = "Pytest Failing Tests", items = qf_entries })
    vim.cmd("copen")
    vim.cmd("cfirst")
end

vim.api.nvim_create_user_command("PytestQuickfix", pytest_quicklist, {})

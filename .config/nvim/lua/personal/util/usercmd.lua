-- Blink Download
local blink_download = function()
    local download = require("blink.cmp.fuzzy.download")
    local files = require("blink.cmp.fuzzy.download.files")

    -- Avoid EEXIST error
    vim.fn.mkdir(files.lib_folder, "p")

    local done = false
    print("Downloading pre-built binary\n")
    download.ensure_downloaded(function()
        print("Finished downloading pre-built binary\n")
        done = true
    end)
    vim.wait(60000, function() return done end, 1000, false)
end
vim.api.nvim_create_user_command("BlinkDownload", blink_download, { desc = "Download binary" })

-- Setup nvim
local setup = function()
    vim.notify("Setting up nvim", vim.log.levels.INFO)

    vim.cmd("Lazy! restore")
    vim.notify("✓ Lazy restore complete", vim.log.levels.INFO)

    vim.cmd("MasonUpdate")
    vim.notify("✓ MasonUpdate complete", vim.log.levels.INFO)

    vim.cmd("MasonLockRestore")
    vim.notify("✓ MasonLockRestore complete", vim.log.levels.INFO)

    vim.cmd("BlinkDownload")
    vim.notify("✓ BlinkDownload complete", vim.log.levels.INFO)

    vim.notify("All setup commands completed!", vim.log.levels.INFO)
end
vim.api.nvim_create_user_command("Setup", setup, { desc = "Run all setup commands" })

-- Ruff to quicklist
local ruff_quicklist = function(opts)
    local path = opts.args
    if not path or path == "" then path = vim.fn.getcwd() end

    local output = vim.fn.systemlist({
        vim.fn.exepath("ruff"),
        "check",
        "--no-fix",
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

vim.api.nvim_create_user_command("RuffQuickfix", ruff_quicklist, {
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

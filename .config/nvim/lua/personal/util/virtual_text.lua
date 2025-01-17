local M = {}

function M.virtual_to_inline_text()
    --[[
    -- Test:
        def test(a):
            return a + 1

        test(1)
        test(test(1.2)) > test(1)
    --]]
    local bufnr = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Save the original cursor position
    local original_pos = { row, col }

    local namespaces = vim.api.nvim_get_namespaces()

    for _, ns_id in pairs(namespaces) do
        -- Get all extmarks on the current line in the current namespace
        local extmarks = vim.api.nvim_buf_get_extmarks(
            bufnr,
            ns_id,
            { row - 1, 0 },
            { row - 1, -1 },
            { details = true }
        )

        table.sort(extmarks, function(a, b) return a[3] > b[3] end)
        for _, extmark in ipairs(extmarks) do
            local virt_text = extmark[4].virt_text
            local virt_text_type = extmark[4].virt_text_pos
            local virt_col = extmark[3] -- Column where the virtual text is attached

            if virt_text and virt_text_type == "inline" then
                for _, text_tuple in ipairs(virt_text) do
                    local content = text_tuple[1]

                    -- Get the current line text
                    local line_text = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]

                    -- Insert the virtual text inline at the correct position
                    line_text = line_text:sub(1, virt_col) .. content .. line_text:sub(virt_col + 1)

                    -- Set the modified line back into the buffer
                    vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { line_text })

                    -- Adjust the original cursor position based on the length of inserted text
                    if virt_col <= original_pos[2] then original_pos[2] = original_pos[2] + #content end
                    virt_col = virt_col + #content

                    -- Optionally, remove the extmark to prevent it from showing as virtual text again
                    vim.api.nvim_buf_del_extmark(bufnr, ns_id, extmark[1])
                end
            end
        end
    end

    -- Restore the cursor to its original position, adjusted for the inserted text
    vim.api.nvim_win_set_cursor(0, original_pos)
end

return M

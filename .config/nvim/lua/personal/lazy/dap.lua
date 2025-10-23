-- Helper to update sign definition partially
local function update_sign(sign_name, new_text, new_texthl)
    local existing = vim.fn.sign_getdefined(sign_name)[1] or {}
    vim.fn.sign_define(sign_name, {
        text = new_text or existing.text,
        texthl = new_texthl or existing.texthl,
        linehl = existing.linehl,
        numhl = existing.numhl,
    })
end

local last_dap_config = nil

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = { "rcarriga/nvim-dap-ui" },
        keys = {
            { "<F2>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
            { "<F3>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
            { "<F4>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
            { "<F5>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
            {
                "<F6>",
                function()
                    local dap = require("dap")
                    if dap.session() then
                        dap.restart()
                    elseif last_dap_config ~= nil then
                        dap.run(last_dap_config)
                    else
                        dap.continue()
                    end
                end,
                desc = "Debug: Restart/Rerun",
            },
            {
                "<leader>b",
                function() require("dap").toggle_breakpoint() end,
                desc = "Debug: Toggle Breakpoint",
            },
            {
                "<leader>B",
                function()
                    vim.ui.input(
                        { prompt = "Breakpoint condition" },
                        function(result) require("dap").set_breakpoint(result) end
                    )
                end,
                desc = "Debug: Set Breakpoint Condition",
            },
            {
                "<leader>i",
                ---@diagnostic disable-next-line: missing-fields
                function() require("dapui").eval(nil, { enter = true }) end,
                desc = "Debug: Eval var under cursor",
            },
            {
                "<F9>",
                function()
                    local mode = vim.fn.mode()
                    local lines

                    if mode == "v" or mode == "V" or mode == "\22" then
                        local start_line = math.min(vim.fn.getpos("v")[2], vim.fn.getpos(".")[2])
                        local end_line = math.max(vim.fn.getpos("v")[2], vim.fn.getpos(".")[2])
                        lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
                        -- Exit visual mode
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
                    else
                        lines = { vim.api.nvim_get_current_line() }
                    end

                    local text = Util.smart_trim_and_dedent(lines)
                    require("dap").repl.execute(text)

                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        local buf_name = vim.api.nvim_buf_get_name(buf)
                        if buf_name:match("dap%-repl") then
                            vim.api.nvim_set_current_win(win)
                            vim.cmd("startinsert")
                            break
                        end
                    end
                end,
                mode = { "n", "v" },
                desc = "Debug: Execute current line(s) in REPL",
            },
        },
        -- `opts` are a table where:
        --
        -- - Keys (`String`) are the name of the language.
        -- - Values (`Table`) can contain two subtables:
        --      - `adapters` (`Table`):
        --          - Keys (`String`) is the adapter name.
        --          - Values (`Table`) the opts for the adapter.
        --      - `configurations` (`List`): configuration for the language.
        config = function(_, opts)
            local dap = require("dap")

            for language_name, language_opts in pairs(opts) do
                -- Adapters
                for adapter_name, adapter_opts in pairs(language_opts.adapters or {}) do
                    dap.adapters[adapter_name] = adapter_opts
                end
                -- Configurations
                dap.configurations[language_name] = language_opts.configurations
            end

            dap.listeners.on_config["store-last-config"] = function(config)
                last_dap_config = vim.deepcopy(config)
                return config
            end

            -- Update sign and color
            update_sign("DapBreakpoint", " ", "DiagnosticSignError")
            update_sign("DapBreakpointCondition", " ", "DiagnosticSignError")
            update_sign("DapBreakpointRejected", " ", "DiagnosticSignError")
            update_sign("DapStopped", "")
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        lazy = true,
        opts = {
            controls = { enabled = false },
            layouts = {
                { elements = { "scopes", "breakpoints", "stacks", "watches" }, size = 40, position = "right" },
                {
                    elements = { { id = "console", size = 0.4 }, { id = "repl", size = 0.6 } },
                    size = 0.25,
                    position = "bottom",
                },
            },
        },
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
            { "theHamsta/nvim-dap-virtual-text", opts = {} },
        },
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")
            local dapvt = require("nvim-dap-virtual-text")
            dapui.setup(opts)

            local open = function()
                dapui.open()
                dapvt.enable()
            end
            dap.listeners.after.event_initialized.dapui_config = open
            dap.listeners.before.attach.dapui_config = open
            dap.listeners.before.launch.dapui_config = open
            dap.listeners.before.event_terminated.dapui_config = function() vim.notify("DAP Terminated") end
            dap.listeners.before.event_exited.dapui_config = function() vim.notify("DAP Exited") end

            -- Exit DAPUI
            vim.keymap.set("n", "<esc>", function()
                dap.disconnect()
                dapui.close()
                dapvt.disable()
            end, { desc = "Debug: Exit" })
        end,
    },
}

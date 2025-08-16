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

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = { "rcarriga/nvim-dap-ui" },
        keys = {
            { "<F2>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
            { "<F3>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
            { "<F4>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
            { "<F5>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
            { "<F6>", function() require("dap").restart() end, desc = "Debug: Restart" },
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
        opts = { controls = { enabled = false } },
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

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local config = require("telescope.config").values
local entry_display = require('telescope.pickers.entry_display')
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")
local log = require('plenary.log').new {
    plugin = 'telescope_k8s',
    level = 'info',
}

---@class TDModule
---@field config TDConfig
---@field setup fun(TDConfig): TDModule

---@class TDConfig
local M = {}

local function kubectl_get()
    local jsonpath = '{range .items[*]}{}{"\\n"}{end}'
    return {
        "/usr/bin/kubectl",
        "get",
        "pods",
        "-o",
        "jsonpath=" .. jsonpath,
    }
end

local entry_maker = function(opts)
    opts = opts or {}

    -- Define the layout of the "columns" in telescope
    local displayer = entry_display.create {
        separator = " ",
        items = {
            { width = 30 },
            { width = 5 },
            { width = 7 },
            { width = 1 },
            { width = 5 },
            { remaining = true },
        },
    }

    -- Define the fields in order that they'll display in telescope
    local make_display = function(entry)
        return displayer {
            entry.name,
            entry.ready,
            entry.status,
            entry.restarts,
            entry.age,
            entry.node,
        }
    end

    return function(entry)
        if entry == "" then
            return nil
        end
        local parsed = vim.json.decode(entry)
        parsed.metadata.managedFields = nil
        -- This table represents an "entry", with everything to display it and to
        -- use it if it is selected.
        return {
            value = parsed,
            ordinal = parsed.metadata.name,
            display = make_display,
            name = parsed.metadata.name,
            ready = parsed.status.containerStatuses[1].ready, --sum if true
            status = parsed.status.phase,
            restarts = parsed.status.containerStatuses[1].restartCount, --sum
            age = parsed.status.startTime,
            node = parsed.spec.nodeName,
        }
    end
end

M.show_pods = function(opts)
    opts = opts or {}

    -- Provide the method that will turn kubectl results into "entry" objects.
    opts.entry_maker = entry_maker()
    pickers.new(opts, {
        finder = finders.new_oneshot_job(kubectl_get(), opts),

        sorter = config.generic_sorter(opts),

        previewer = previewers.new_buffer_previewer({
            title = "k8s pods",
            define_preview = function(self, entry)
                vim.api.nvim_buf_set_lines(
                    self.state.bufnr,
                    0,
                    0,
                    true,
                    vim.split(vim.inspect(entry.value), "\n")
                )
                utils.highlighter(self.state.bufnr, "lua")
            end
        }),

        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                log.debug('Selected', selection)
                local command = {
                    'edit',
                    'term://kubectl',
                    'edit',
                    'pod',
                    selection.value.metadata.name,
                }
                log.debug('Running', command)
                vim.cmd(vim.fn.join(command, ' '))
            end)
            return true
        end,

    }):find()
end
--
---@param config TDConfig
M.setup = function(config)
    M.config = config
end

return M

local M = {}

local win = require("whid.common.window")
local km = require("whid.common.keymap")

function M.get_data(position)
	local result = vim.api.nvim_call_function("systemlist", {
		"git diff-tree --no-commit-id --name-only -r HEAD~" .. position,
	})

	if #result == 0 then
		result = table.insert(result, "")
	end
	return result
end

function M.whid()
	local data = M.get_data(0)
	win.open("whid", "What I Do ?")
	km.mappings()
	win.update(data)
	win.init_cursor(4)
end

return M

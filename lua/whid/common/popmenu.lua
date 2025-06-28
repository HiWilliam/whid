local M = {}

local symbols = require("whid.utils.symbols")

--- @param callback function
function M.SymbolSelect(callback)
	local list = {}
	for _, v in pairs(symbols) do
		table.insert(list, v)
	end
	vim.ui.select(list, {
		prompt = "Choose an option:",
		format_item = function(item)
			return string.format("%s %s", item.name, item.code)
		end,
	}, function(choice)
		if choice then
			callback(choice)
		end
	end)
end

return M

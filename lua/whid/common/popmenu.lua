local M = {}

local symbols = require("whid.utils.symbols")

function M.SymbolSelect()
	local list = {}
	for _, v in pairs(symbols) do
		table.insert(list, v)
	end
	vim.ui.select(list, {
		prompt = "Choose an option:",
		format_item = function(item)
			return string.format("%s %s //%s", item.name, item.code, item.desc)
		end,
	}, function(choice)
		if choice then
			print("You selected:", choice)
		else
			print("Cancelled!")
		end
	end)
end

return M

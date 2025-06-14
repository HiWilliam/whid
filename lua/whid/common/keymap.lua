local M = {}

local win = require("whid.common.window")

---@class KeymapOpts
---@field silent? boolean
---@field noremap? boolean
---@field nowait? boolean
---@field buffer? boolean
---@field desc? string

---@alias KeymapLhs string
---@alias KeymapRhs string|function

---@class KeymapDefinition
---@field [1] string       -- mode (e.g., "n", "i")
---@field [2] KeymapLhs    -- lhs (e.g., "<Leader>q")
---@field [3] KeymapRhs    -- rhs (e.g., ":q<CR>" or function())
---@field [4]? KeymapOpts  -- opts (optional)

---@type KeymapDefinition[]
M.mappings = {
	{ "n", "q", win.close, { silent = true, noremap = true, nowait = true, buffer = true } },
}

--- @param maps KeymapDefinition[]
function M.set(maps)
	if #maps ~= 0 then
		for _, v in ipairs(maps) do
			table.insert(M.mappings, v)
		end
	end

	for _, v in ipairs(M.mappings) do
		vim.keymap.set(unpack(v))
	end
end

return M

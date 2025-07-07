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
	{ "n", "q", win.close, { desc = "Close Window" } },
}

local mapping_opts = { silent = true, noremap = true, nowait = true, buffer = true }

M.unmappings = {
	{ "n", "<C-h>" },
	{ "n", "<C-k>" },
	{ "n", "<C-j>" },
	{ "n", "<C-l>" },
}

--- @param maps KeymapDefinition[]
function M.set(maps)
	for _, v in ipairs(M.mappings) do
		v[4] = vim.tbl_extend("force", mapping_opts, v[4])
	end

	if #maps ~= 0 then
		for _, v in ipairs(maps) do
			v[4] = vim.tbl_extend("force", mapping_opts, v[4])
			table.insert(M.mappings, v)
		end
	end

	for _, v in ipairs(M.mappings) do
		vim.keymap.set(unpack(v))
	end

	for _, v in ipairs(M.unmappings) do
		vim.keymap.set(v[1], v[2], "", mapping_opts)
	end
end

return M

local M = {
	--uncheck = "\u{2610}",
	--checked = "\u{2611}",
	canceled = {
		name = "canceled",
		code = "\u{274c}",
		desc = "已取消",
	},
	uncheck = {
		name = "uncheck",
		code = "\u{2B1c}",
		desc = "未确认",
	},
	checked = {
		name = "checked",
		code = "\u{2705}",
		desc = "已确认",
	},
	red_circle = {
		name = "red_circle",
		code = "\u{1F534}",
		desc = "紧急",
	},
	yel_circle = {
		name = "yel_circle",
		code = "\u{1F7E1}",
		desc = "重要",
	},
	gre_circle = {
		name = "gre_circle",
		code = "\u{1F7E2}",
		desc = "正常",
	},
	blu_circle = {
		name = "blu_circle",
		code = "\u{1F535}",
		desc = "一般",
	},
	flashing = {
		name = "flashing",
		code = "\u{26A1}",
		desc = "快速",
	},
	firing = {
		name = "firing",
		code = "\u{1F525}",
		desc = "热点",
	},
}

local STATUES = { "canceled", "uncheck", "checked" }
local LABELS = { "red_circle", "yel_circle", "gre_circle", "blu_circle", "flashing", "firing" }

---@param name string
---@return string
function M.get_code(name)
	return M[name].code
end

function M.get_statues()
	return STATUES
end

function M.get_labels()
	return LABELS
end

---@return string[]
function M.get_labels_code(labels)
	local codes = {}
	for _, v in ipairs(labels) do
		table.insert(codes, M[v].code)
	end
	return codes
end

return M

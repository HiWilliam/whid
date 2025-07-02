---@class M
---@field tasks task[]
local M = {
	tasks = {},
}

---@class task
---@field id string Id
---@field module?  string 模块
---@field status  string 任务状态
---@field title  string 任务标题
---@field content?  string 任务内容
---@field labels?  string[] 标签数组
---@field is_deleted?  boolean 删除标记
local task = {
	id = "",
	module = "",
	status = "",
	title = "",
	content = "",
	labels = {},
	is_deleted = false,
}

local file = require("whid.utils.file")

--- @param path string
function M.load_all(path)
	local content = file.read(path)
	if not content then
		print(string.format("Open Json File: %s failed", path))
		return
	end

	M.tasks = vim.json.decode(content)
end

---@return task[]
function M.get_all_tasks()
	return M.tasks
end

---@return table<string,string>
function M.get_task_maps()
	local map = {}
	for _, v in ipairs(M.tasks) do
		map[v.id] = v.title
	end

	return map
end

---@param path string
---@return string?
function M.save_all(path)
	return file.write(path, vim.json.encode(M.tasks))
end

return M

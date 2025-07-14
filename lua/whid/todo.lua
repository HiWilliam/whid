local M = {}

local win = require("whid.common.window")
local symbols = require("whid.utils.symbols")
local select = require("whid.common.popmenu")
local json = require("whid.utils.json")

local line_format = "%s %d. [%s]: %s"

local is_preview = false

---@return string
local function genUniqueId()
	local time = vim.loop.hrtime()
	local rand = math.random(10000, 99999)
	return string.format("uv_%s_%d", time, rand)
end

---@return task?
local function getInput()
	local user_input = vim.fn.input({ prompt = "请输入: " })
	if #user_input == 0 then
		return nil
	end
	local module = user_input:match("%[(.-)%]") or "default"
	local title = user_input:match("%]:*%s*(.*)") or user_input
	---@type task
	local task = {
		id = genUniqueId(),
		module = module,
		title = title,
		status = symbols.uncheck.name,
		is_deleted = false,
	}
	return task
end

function M.input()
	win.update_line(function()
		local task = getInput()
		if task == nil then
			return
		end
		local count = vim.api.nvim_buf_line_count(0)

		vim.api.nvim_buf_set_lines(
			0,
			-1,
			-1,
			false,
			{ string.format(line_format, symbols.uncheck.code, count, task.module, task.title) }
		)

		table.insert(json.tasks, task)
	end)
end

function M.input_after()
	local task = getInput()
	if task == nil then
		return
	end
	local index = vim.api.nvim_win_get_cursor(0)[1] - 1
	table.insert(json.tasks, index + 1, task)
	M.load()
end

function M.input_before()
	local task = getInput()
	if task == nil then
		return
	end
	local index = vim.api.nvim_win_get_cursor(0)[1] - 1
	index = index - 1 <= 0 and 1 or index
	table.insert(json.tasks, index, task)
	M.load()
end

function M.toggle_preview()
	local index = vim.api.nvim_win_get_cursor(0)[1] - 1
	local task = json.tasks[index]
	if task == nil then
		vim.notify("任务不存在" .. index, vim.log.levels.ERROR)
		return
	end

	if is_preview then
		M.load()
		is_preview = false
	else
		M.preview(task)
		is_preview = true
	end
end
---@param task task
function M.preview(task)
	local status_code = symbols.get_code(task.status)
	local label_codes = symbols.get_labels_code(task.labels or {})
	local labels = #label_codes > 0 and table.concat(label_codes) or symbols.blu_circle.code

	local content = {
		---string.format("### %s", task.title),
		---string.format("** 模块: ** %s", task.module),
		---string.format("* 状态: * %s", status_code),
		---string.format("* 标签: * %s", labels),
		string.format("%s", task.content or task.title),
	}
	win.update(content)
end

function M.load()
	local lines = {}
	for k, task in ipairs(json.tasks) do
		local status_code = symbols.get_code(task.status)
		local line = string.format(line_format, status_code, k, task.module, task.title)
		if task.is_deleted then
			line = string.format("~~%s~~", line)
		end

		table.insert(lines, line)
	end

	win.update(lines)

	for k, v in ipairs(json.tasks) do
		local labels = symbols.get_labels_code(v.labels ~= nil and v.labels or { symbols.blu_circle.name })
		win.set_right_icons(k, labels)
	end
end

function M.save()
	local err = json.save_all(M.save_file)

	if err ~= nil then
		vim.notify("Save failed:" .. err, vim.log.levels.ERROR)
		return
	end

	vim.notify("Save successed")
end
---@param key string
function M.update(key)
	local enable_updates = {
		module = true,
		title = true,
	}
	if not enable_updates[key] then
		vim.notify("Error Update Key", vim.log.levels.ERROR)
		return
	end

	local index = win.get_current_line()
	local task = json.tasks[index]
	local input = vim.fn.input({ default = task[key] })
	if not input or input == "" then
		input = task[key]
	end

	json.tasks[index][key] = input

	local status_code = symbols.get_code(task.status)
	win.update_line(function()
		vim.api.nvim_buf_set_lines(
			0,
			index,
			index + 1,
			false,
			{ string.format(line_format, status_code, index, task.module, task.title) }
		)
	end)
end

function M.mark_status()
	local index = vim.api.nvim_win_get_cursor(0)[1] - 1
	local task = json.tasks[index]
	select.StatusSelect(function(choice)
		win.update_line(function()
			vim.api.nvim_buf_set_lines(0, index, index + 1, false, {
				string.format(line_format, choice.code, index, task.module, task.title),
			})
		end)
		json.tasks[index].status = choice.name
		--- 同时更新virtu_text 防止错位
		local labels = symbols.get_labels_code(task.labels ~= nil and task.labels or { symbols.blu_circle.name })
		win.set_right_icons(index, labels)
	end)
end

function M.mark_label()
	local index = vim.api.nvim_win_get_cursor(0)[1] - 1
	select.LabelSelect(function(choice)
		win.update_line(function()
			win.set_right_icons(index, { choice.code })
		end)
		json.tasks[index].labels = { choice.name }
	end)
end

function M.toggle_delete()
	local index = vim.api.nvim_win_get_cursor(0)[1] - 1
	local task = json.tasks[index]

	local format = line_format
	task.is_deleted = not task.is_deleted
	if task.is_deleted then
		format = "~~" .. line_format .. "~~"
	end
	local status_code = symbols.get_code(task.status)

	win.update_line(function()
		vim.api.nvim_buf_set_lines(
			0,
			index,
			index + 1,
			false,
			{ string.format(format, status_code, index, task.module, task.title) }
		)
	end)

	json.tasks[index] = task
end

function M.pyhsical_delete()
	win.update_line(function()
		local index = vim.api.nvim_win_get_cursor(0)[1] - 1
		vim.cmd("delete")
		table.remove(json.tasks, index)

		M.load()
	end)
end

function M.undo()
	win.update_line(function()
		vim.cmd("undo")
	end)
end

---@param index string
function M.swap(index)
	if not win.is_open() then
		return
	end
	local target = tonumber(index)
	if not target then
		vim.notify("请输入数字类型", vim.log.levels.ERROR)
		return
	end

	if target <= 0 or target > #json.tasks then
		vim.notify(string.format("参数范围为(0, %d]", #json.tasks), vim.log.levels.ERROR)
		return
	end
	local current = win.get_current_line()
	json.tasks[target], json.tasks[current] = json.tasks[current], json.tasks[target]
	M.load()
end

function M.goto()
    local timeout = 500  -- 超时时间（毫秒）
    local start_time = vim.loop.now()
    local num_str = ""

    while (vim.loop.now() - start_time) < timeout do
        local char = vim.fn.getchar(0)  -- 非阻塞获取
        
        if char ~= 0 then  -- 有按键输入
            if type(char) == 'number' then
                char = string.char(char)
            end
            
            if char:match('%d') then
                num_str = num_str .. char  -- 追加数字
                start_time = vim.loop.now()  -- 重置超时计时
            else
                -- 遇到非数字键，返回原始功能
                return 'g' .. num_str .. char
            end
        else
            vim.wait(10)  -- 小延迟防止CPU占用过高
        end
    end
    
    if #num_str <= 0 then
        return
    end

    local target = tonumber(num_str)
    if not target then
        vim.notify("请输入数字类型", vim.log.level.ERROR)
        return
    end

    if target <= 0 or target > #json.tasks then
        vim.notify(string.format("参数范围为(0, %d]", #json.tasks), vim.log.levels.ERROR)
		return
    end

    win.move_cursor(target+1, 0)
end

function M.setup(cfg)
	if type(cfg) ~= "table" then
		cfg = {}
	end
	M.save_file = cfg.save_file or "./.vscode/todo.md"
	json.load_all(M.save_file)

	win.open("markdown", "TODO List")
	M.load()
	win.init_cursor(2)
end

return M

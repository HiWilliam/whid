local M = {}

local api = vim.api
local buf, win
local is_open = false

local virtu_text_ids = {}

local function center(str)
	local width = api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(" ", shift) .. str
end

--- Open buf window
--- @param filetype string
--- @param title string
function M.open(filetype, title)
	buf = api.nvim_create_buf(false, true)

	api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	api.nvim_buf_set_option(buf, "filetype", filetype)
	api.nvim_buf_set_option(buf, "undolevels", 1000)

	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local opts = {
		style = "minimal",
		border = "rounded",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	win = api.nvim_open_win(buf, true, opts)

	api.nvim_win_set_option(win, "cursorline", true)

	api.nvim_buf_set_lines(buf, 0, -1, false, { center(title), "", "" })
	api.nvim_buf_add_highlight(buf, -1, "WhidHeader", 0, 0, -1)

	is_open = true
end

--- Update content in buffer
--- @param data string[]
function M.update(data)
	api.nvim_buf_set_option(buf, "modifiable", true)

	if #data == 0 then
		table.insert(data, "")
	end
	for k, v in pairs(data) do
		data[k] = string.format("%s", v)
	end
	api.nvim_buf_set_lines(buf, 1, -1, false, data)
	api.nvim_buf_set_option(buf, "modifiable", false)
end

---@param func function
function M.update_line(func)
	api.nvim_buf_set_option(buf, "modifiable", true)
	func()
	api.nvim_buf_set_option(buf, "modifiable", false)
end

function M.init_cursor(line)
	api.nvim_win_set_cursor(win, { line, 0 })
end

function M.close()
	is_open = false
	api.nvim_win_close(win, true)
end

function M.open_file()
	local str = api.nvim_get_current_line()
	M.close_window()
	api.nvim_command("edit " .. str)
end

---@param row integer
---@param col integer
function M.move_cursor(row, col)
	vim.schedule(function()
		api.nvim_win_set_cursor(win, { row, col })
	end)
end

function M.set_right_icons(line_num, labels)
	local line = api.nvim_buf_get_lines(buf, line_num, line_num + 1, false)[1] or ""
	local line_length = #line

	local ns_id = api.nvim_create_namespace("todo")

	if virtu_text_ids[line_num] ~= nil then
		api.nvim_buf_del_extmark(buf, ns_id, virtu_text_ids[line_num])
	end

	-- 添加虚拟文本（右对齐）
	virtu_text_ids[line_num] = api.nvim_buf_set_extmark(buf, ns_id, line_num, line_length, {
		virt_text = { { table.concat(labels), "Label" } },
		virt_text_pos = "right_align", -- 关键参数：右对齐
		hl_mode = "combine",
	})
end

---@return integer
function M.get_current_line()
	return api.nvim_win_get_cursor(win)[1] - 1
end

function M.is_open()
	return is_open
end

return M

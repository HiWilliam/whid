local M = {}

local api = vim.api
local buf, win

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
	local border_buf = api.nvim_create_buf(false, true)

	api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	api.nvim_buf_set_option(buf, "filetype", filetype)

	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local border_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1,
	}

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	local border_lines = { "╔" .. string.rep("═", win_width) .. "╗" }
	local middle_line = "║" .. string.rep(" ", win_width) .. "║"
	for i = 1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, "╚" .. string.rep("═", win_width) .. "╝")
	api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	local border_win = api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts)
	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

	api.nvim_win_set_option(win, "cursorline", true)

	api.nvim_buf_set_lines(buf, 0, -1, false, { center(title), "", "" })
	api.nvim_buf_add_highlight(buf, -1, "WhidHeader", 0, 0, -1)
end

--- Update content in buffer
--- @param data any
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

function M.init_cursor(line)
	api.nvim_win_set_cursor(win, { line, 0 })
end

function M.close()
	api.nvim_win_close(win, true)
end

function M.open_file()
	local str = api.nvim_get_current_line()
	M.close_window()
	api.nvim_command("edit " .. str)
end

function M.move_cursor()
	local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
	api.nvim_win_set_cursor(win, { new_pos, 0 })
end

return M

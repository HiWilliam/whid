local M = {}

local win = require("whid.common.window")
local file = require("whid.utils.file")
local symbols = require("whid.utils.symbols")

function M.input()
	local max = vim.api.nvim_buf_line_count(0)
	local user_input = vim.fn.input({ prompt = "请输入: " })

	vim.api.nvim_buf_set_option(0, "modifiable", true)
	vim.api.nvim_buf_set_lines(0, -1, -1, false, { string.format("%s  %d. %s", symbols.uncheck, max, user_input) })
	vim.api.nvim_buf_set_option(0, "modifiable", false)
end

function M.load()
	local res = file.read(M.save_file)
	if not res then
		return
	end

	local lines = {}
	for line in res:gmatch("[^\n]+") do
		table.insert(lines, line)
	end

	win.update(lines)
end

function M.save()
	local content = vim.api.nvim_buf_get_lines(0, 1, -1, false)
	if #content == 0 then
		vim.notify("No content")
		return
	end

	local err = file.save(M.save_file, content)
	if err then
		vim.notify("Save failed:" .. err, vim.log.levels.ERROR)
		return
	end

	vim.notify("Save successed")
end

function M.update()
	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local content = vim.api.nvim_get_current_line()
	content = vim.fn.input({ default = content })
	vim.api.nvim_buf_set_option(0, "modifiable", true)
	vim.api.nvim_buf_set_lines(0, line, line + 1, false, { content })
	vim.api.nvim_buf_set_option(0, "modifiable", false)
end

function M.toggle_check()
	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local content = vim.api.nvim_get_current_line()
	local code, _ = content:match(symbols.uncheck)
	local status = code == symbols.uncheck and code or symbols.checked
	local replace = status == symbols.uncheck and symbols.checked or symbols.uncheck
	content = content:gsub(status, replace, 1)

	print("content:" .. content)
	vim.api.nvim_buf_set_option(0, "modifiable", true)
	vim.api.nvim_buf_set_lines(0, line, line + 1, false, {
		content,
	})
	vim.api.nvim_buf_set_option(0, "modifiable", false)
end

function M.toggle_delete()
	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local content = vim.api.nvim_get_current_line()
	local mc = content:match("~~(.-)~~")
	if not mc then
		content = string.format("~~%s~~", content)
	else
		content = mc
	end

	vim.api.nvim_buf_set_option(0, "modifiable", true)
	vim.api.nvim_buf_set_lines(0, line, line + 1, false, { content })
	vim.api.nvim_buf_set_option(0, "modifiable", false)
end

function M.pyhsical_delete()
	vim.api.nvim_buf_set_option(0, "modifiable", true)
	vim.cmd("delete")
	vim.api.nvim_buf_set_option(0, "modifiable", false)
end

function M.setup(cfg)
	if type(cfg) ~= "table" then
		cfg = {}
	end
	M.save_file = cfg.save_file or "./.vscode/todo.md"

	win.open("markdown", "TODO List")
	M.load()
	win.init_cursor(1)
end

return M

local M = {}

local win = require("whid.common.window")
local file = require("whid.utils.file")
local symbols = require("whid.utils.symbols")
local select = require("whid.common.popmenu")

function M.input()
	win.update_buf(function()
		local user_input = vim.fn.input({ prompt = "请输入: " })
		local count = vim.api.nvim_buf_line_count(0)
		if not user_input then
			return
		end

		vim.api.nvim_buf_set_lines(
			0,
			-1,
			-1,
			false,
			{ string.format("%s %d. %s", symbols.uncheck.code, count, user_input) }
		)
	end)
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

	lines = M.reorder(lines)

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
	win.update_buf(function()
		local line = vim.api.nvim_win_get_cursor(0)[1] - 1
		local content = vim.api.nvim_get_current_line()
		local slices = string.gmatch(content, "%S+")
		local items = {}
		for word in slices do
			table.insert(items, word)
		end

		if #items > 2 then
			content = table.concat({ unpack(items, 3) }, " ")
		end

		local input = vim.fn.input({ default = content })
		if not input or input == "" then
			input = content
		end

		vim.api.nvim_buf_set_lines(0, line, line + 1, false, { string.format("%s %d. %s", items[1], items[2], input) })
	end)
end

function M.toggle_check()
	select.SymbolSelect(function(choice)
		local line = vim.api.nvim_win_get_cursor(0)[1] - 1
		local content = vim.api.nvim_get_current_line()
		print(string.format("choice: name: %s, code: %s, desc: %s ", choice.name, choice.code, choice.desc))
		content = content:gsub("[^\128-\191][\128-\191]*", choice.code, 1)

		vim.api.nvim_buf_set_option(0, "modifiable", true)
		vim.api.nvim_buf_set_lines(0, line, line + 1, false, {
			content,
		})
		vim.api.nvim_buf_set_option(0, "modifiable", false)
	end)
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

	local lines = vim.api.nvim_buf_get_lines(0, 1, -1, false)

	lines = M.reorder(lines)

	win.update(lines)

	vim.api.nvim_buf_set_option(0, "modifiable", false)
end

--- @param  data string[]
--- @return string[]
function M.reorder(data)
	local result = {}
	for k, v in ipairs(data) do
		local line = v:gsub("%d+", k, 1)
		table.insert(result, line)
	end

	return result
end

function M.undo()
	vim.api.nvim_buf_set_option(0, "modifiable", true)
	vim.cmd("undo")
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

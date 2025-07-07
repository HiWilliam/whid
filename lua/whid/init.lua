-- whid/init.lua
local M = {}

local todo = require("whid.todo")
local km = require("whid.common.keymap")

local todo_maps = {
	{ "n", "i", todo.input, { desc = "Insert a new task" } },
	{ "n", "o", todo.input_after, { desc = "Insert a new task after cursor " } },
	{ "n", "O", todo.input_before, { desc = "Insert a new task before cursor " } },
	{ "n", "w", todo.save, { desc = "Save task list to file" } },
	{ "n", "r", todo.load, { desc = "Reload task list " } },
	{ "n", "ds", todo.toggle_delete, { desc = "Toggle delete task soft " } },
	{ "n", "dd", todo.pyhsical_delete, { desc = "Delete the task pyhsically (need save to file)" } },
	{
		"n",
		"ct",
		function()
			todo.update("title")
		end,
		{ desc = "Change task title" },
	},
	{
		"n",
		"cm",
		function()
			todo.update("module")
		end,
		{ desc = "Change task module" },
	},
	{ "n", "ms", todo.mark_status, { desc = "Mark task status with selected item" } },
	{ "n", "ml", todo.mark_label, { desc = "Mark task label with selected item" } },
	{ "n", "u", todo.undo, { desc = "Undo latest operation" } },
	{ "n", "p", todo.toggle_preview, { desc = "Toggle preview task detail" } },
}
-- Main WHID command
function M.setup(cfg)
	vim.api.nvim_create_user_command("TodoList", function()
		todo.setup({
			save_file = cfg.save_file or "/root/todos/default.md",
		})
		km.set(todo_maps)
	end, {})
	vim.api.nvim_create_user_command("TodoSwap", function(opts)
		todo.swap(opts.args)
	end, { nargs = 1 })
end

-- Automatically call setup when required
M.setup()

return M

-- whid/init.lua
local M = {}

local todo = require("whid.todo")
local km = require("whid.common.keymap")
-- Highlight group definitions
vim.api.nvim_set_hl(0, "WhidHeader", { link = "Number" })
vim.api.nvim_set_hl(0, "WhidSubHeader", { link = "Identifier" })
local todo_maps = {
	{ "n", "i", todo.input, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "o", todo.input_after, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "O", todo.input_before, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "w", todo.save, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "r", todo.load, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "ds", todo.toggle_delete, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "dd", todo.pyhsical_delete, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "c", todo.update, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "ms", todo.mark_status, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "ml", todo.mark_label, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "u", todo.undo, { silent = true, noremap = true, nowait = true, buffer = true } },
	{ "n", "p", todo.toggle_preview, { silent = true, noremap = true, nowait = true, buffer = true } },
}
-- Main WHID command
function M.setup(cfg)
	vim.api.nvim_create_user_command("Whid", function()
		require("whid.whid"):whid()
	end, {})

	vim.api.nvim_create_user_command("TodoList", function()
		todo.setup({
			save_file = cfg.save_file or "/root/todos/default.md",
		})
		km.set(todo_maps)
	end, {})
end

-- Automatically call setup when required
M.setup()

return M

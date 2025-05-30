-- whid/init.lua
local M = {}

-- Highlight group definitions
vim.api.nvim_set_hl(0, "WhidHeader", { link = "Number" })
vim.api.nvim_set_hl(0, "WhidSubHeader", { link = "Identifier" })

-- Main WHID command
function M.setup()
	vim.api.nvim_create_user_command("Whid", function()
		require("whid.whid"):whid()
	end, {})
end

-- Automatically call setup when required
M.setup()

return M

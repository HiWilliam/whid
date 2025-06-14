local M = {}

--- @param filename string
--- @return any|boolean
function M.read(filename)
	local f, err = io.open(filename, "r")
	if not f then
		vim.notify("Open file failed:" .. err)
		return false
	end

	local content = f:read("*a")
	f:close()

	return content
end

--- @param filename string
--- @param data string[]|number[]
--- @return string?
function M.save(filename, data)
	local f, err = io.open(filename, "w")
	if not f then
		return err
	end

	for _, v in ipairs(data) do
		res, err = f:write(v:match("^%s*(.*)") .. "\n")
		if not res then
			f:close()
			return err
		end
	end

	f:close()
end

return M

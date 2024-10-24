local function count_of_lines(path)
	local file, err = io.open(path, "r")
	local count = 0
	if not file then
		print("Error opening file:" .. err)
		return 0
	end
	for _ in file:lines() do
		count = count + 1
	end
	file:close()
	if count > 100 then
		return 100
	end
	return 2
end

local function filetype(path)
	-- Get the file extension
	local filename = vim.fn.fnamemodify(path, ":t")
	local extension = filename:match("^.+%.(.+)$")
	if extension then
		return extension
	else
		return "text"
	end
end

local M = {}
M.get_file_with_range = function(path, left, right)
	left = left or 1
	right = right or count_of_lines(path)
	local file, err = io.open(path, "r")
	local data = {}
	if not file then
		print("Error opening file:" .. err)
		return {}
	end
	local lineNumber = 0
	for line in file:lines() do
		lineNumber = lineNumber + 1
		if lineNumber >= left and lineNumber <= right then
			table.insert(data, line)
		end
	end
	file:close()
	local res = {}
	table.insert(res, "```" .. filetype(path) .. "\n")
	table.insert(res, table.concat(data, "\n"))
	table.insert(res, "\n```\n")
	return res
end

local is_valid_file = function(path)
	if vim.fn.filereadable(path) == 1 then
		return true
	end
	return false
end

M.oldfiles = function()
	local oldfiles = {}
	for _, v in ipairs(vim.v.oldfiles) do
		if string.sub(v, 1, 1) == "/" and is_valid_file(v) then
			table.insert(oldfiles, v)
		end
	end
	return oldfiles
end

M.create_cmp_items = function(request)
	local input = string.sub(request.context.cursor_before_line, request.offset - 1)
	local prefix = string.sub(request.context.cursor_before_line, 1, request.offset - 1)
	local keys = M.oldfiles()
	local items = {}
	for _, path in ipairs(keys) do
		local filename = vim.fn.fnamemodify(path, ":t")
		local textEditTable = M.get_file_with_range(path, 1, 5)
		local textEdit = table.concat(textEditTable, "\n")
		table.insert(items, {
			filterText = filename,
			label = filename,
			detail = path,
			textEdit = {
				newText = textEdit,
				range = {
					start = {
						line = request.context.cursor.row - 1,
						character = request.context.cursor.col - 1 - #input,
					},
					["end"] = {
						line = request.context.cursor.row - 1,
						character = request.context.cursor.col - 1,
					},
				},
			},
		})
	end
	return items
end

return M

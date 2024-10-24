local M = {}

M.setup = function()
	local ok, cmp = pcall(require, "cmp")
	if not ok then
		return
	end

	cmp.register_source("codesnip", require("codemd.source"))
	cmp.setup.filetype("markdown", { sources = cmp.config.sources({ { name = "codesnip" } }) })
end

return M

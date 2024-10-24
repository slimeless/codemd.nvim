local utils = require("codemd.utils")

local source = {}

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
	return true
end

---Return the debug name of this source (optional).
---@return string
function source:get_debug_name()
	return "debug name"
end

---Return LSP's PositionEncodingKind.
---@NOTE: If this method is omitted, the default value will be `utf-16`.
---@return lsp.PositionEncodingKind
function source:get_position_encoding_kind()
	return "utf-16"
end

---Return the keyword pattern for triggering completion (optional).
---If this is omitted, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
---@return string
function source:get_keyword_pattern()
	return [[\k\+]]
end

---Return trigger characters for triggering completion (optional).
function source:get_trigger_characters()
	return { "@" }
end

---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
	local items = utils.create_cmp_items(params)
	callback(items)
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
	local table_doc = utils.get_file_with_range(completion_item.detail, 1, 5)
	local doc = table.concat(table_doc, "\n")
	completion_item.documentation = doc
	callback(completion_item)
end

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
	callback(completion_item)
end

return source

local source = {}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.is_available = function()
  return vim.bo.omnifunc ~= ''
end

source.get_keyword_pattern = function()
  return [[\k\+]]
end

source.complete = function(self, params, callback)
  local offset = self:_invoke(vim.bo.omnifunc, { 1, '' })
  if type(offset) ~= 'number' then
    return callback()
  end
  local result = self:_invoke(vim.bo.omnifunc, { 0, string.sub(params.context.cursor_before_line, offset) })
  if type(result) ~= 'table' then
    return callback()
  end

  local items = {}
  for _, v in ipairs(result) do
    if type(v) == 'string' then
      table.insert(items, {
        label = v,
      })
    elseif type(v) == 'table' then
      table.insert(items, {
        label = v.abbr or v.word,
        insertText = v.word,
      })
    end
  end
  callback({ items = items })
end

source._invoke = function(_, func, args)
  local prev_pos = vim.api.nvim_win_get_cursor(0)
  local _, result = pcall(function()
    return vim.api.nvim_call_function(func, args)
  end)
  local next_pos = vim.api.nvim_win_get_cursor(0)

  if prev_pos[1] ~= next_pos[1] or prev_pos[2] ~= next_pos[2] then
    vim.api.nvim_win_set_cursor(0, prev_pos)
  end

  return result
end

return source


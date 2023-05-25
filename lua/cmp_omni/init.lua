local source = {}

local default_option = {
  disable_omnifuncs = { 'v:lua.vim.lsp.omnifunc' }
}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.is_available = function()
  return vim.bo.omnifunc ~= '' and vim.api.nvim_get_mode().mode == 'i' and not vim.tbl_contains(default_option.disable_omnifuncs, vim.bo.omnifunc)
end

source.get_position_encoding_kind = function()
  return 'utf-8'
end

source.get_keyword_pattern = function()
  return [[\k\+]]
end

source.complete = function(self, params, callback)
  local offset_0 = self:_invoke(vim.bo.omnifunc, { 1, '' })
  if type(offset_0) ~= 'number' then
    return callback()
  end
  local result = self:_invoke(vim.bo.omnifunc, { 0, string.sub(params.context.cursor_before_line, offset_0 + 1) })
  if type(result) ~= 'table' then
    return callback()
  end

  local text_edit_range = {
    start = {
      line = params.context.cursor.line,
      character = offset_0,
    },
    ['end'] = {
      line = params.context.cursor.line,
      character = params.context.cursor.character,
    },
  }

  local items = {}
  for _, v in ipairs(result) do
    if type(v) == 'string' then
      table.insert(items, {
        label = v,
        textEdit = {
          range = text_edit_range,
          newText = v,
        },
      })
    elseif type(v) == 'table' then
      table.insert(items, {
        label = v.abbr or v.word,
        textEdit = {
          range = text_edit_range,
          newText = v.word,
        },
        labelDetails = {
          detail = v.kind,
          description = v.menu,
        },
      })
    end
  end
  callback({ items = items })
end

source._invoke = function(_, func, args)
  local prev_pos = vim.api.nvim_win_get_cursor(0)
  local _, result = pcall(function()
    return vim.fn['cmp_omni#invoke'](func, args)
  end)
  local next_pos = vim.api.nvim_win_get_cursor(0)
  if prev_pos[1] ~= next_pos[1] or prev_pos[2] ~= next_pos[2] then
    vim.api.nvim_win_set_cursor(0, prev_pos)
  end
  return result
end



return source


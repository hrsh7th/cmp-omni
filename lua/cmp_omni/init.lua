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
local kind_map =
  (function()
  local lsp_kinds = vim.lsp.protocol.CompletionItemKind

  local acc = {
    v = lsp_kinds.Variable,
    f = lsp_kinds.Function,
    p = lsp_kinds.Function,
    m = lsp_kinds.Property,
    t = lsp_kinds.TypeParameter,
    d = lsp_kinds.Macro,
    s = lsp_kinds.Struct
  }

  for key, val in pairs(lsp_kinds) do
    if type(key) == "string" and type(val) == "number" then
      acc[string.lower(key)] = val
    end
  end

  return acc
end)()
local completefunc_items = function(matches)
  vim.validate {
    matches = {matches, "table"},
    words = {matches.words, "table", true}
  }

  local words = matches.words and matches.words or matches

  local parse = function(match)
    vim.validate {
      match = {match, "table"},
      word = {match.word, "string"},
      abbr = {match.abbr, "string", true},
      menu = {match.menu, "string", true},
      kind = {match.kind, "string", true},
      info = {match.info, "string", true}
    }

    local kind_taken, menu_taken = false, false

    local kind = (function()
      local lkind = string.lower(match.kind or "")
      if kind_map[lkind] then
        kind_taken = true
        return kind_map[lkind]
      end
      local lmenu = string.lower(match.menu or "")
      if kind_map[lmenu] then
        menu_taken = true
        return kind_map[lmenu]
      end

      return nil
    end)()

    local label = (function()
      local label = match.abbr or match.word
      if match.menu and not menu_taken then
        menu_taken = true
        return label .. "\t" .. match.menu .. ""
      else
        return label
      end
    end)()

    local detail = (function()
      if match.info then
        return match.info
      elseif match.kind and not kind_taken then
        return match.kind
      else
        return nil
      end
    end)()

    local item = {
      label = label,
      insertText = match.word,
      kind = kind,
      detail = detail
    }

    return item
  end

  local acc = {}
  for _, match in ipairs(words) do
    local item = parse(match)
    table.insert(acc, item)
  end

  return acc
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

  local items = completefunc_items(result)

  if params.offset < offset_0 + 1 then
    local follow = string.sub(params.context.cursor_before_line, params.offset, offset_0)
    for _, item in ipairs(items) do
      if item.insertText then
        item.insertText = follow .. item.insertText
      end
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


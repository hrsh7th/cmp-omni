local sandbox = {}

function sandbox.omnifunc(findstart)
  if findstart == 1 then
    local p = vim.fn.searchpos([[\k*\%#]], 'cznw')
    vim.pretty_print({ pos = p })
    if p[1] == 0 then
      return -1
    end
    return p[1]
  end
  return { 'abcdef', 'ghijkl', 'mnopqrst', 'uvwxyz' }
end

return sandbox

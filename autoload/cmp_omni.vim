function! cmp_omni#invoke(func, ...) abort
  if a:func =~# '^v:lua\.'
    return luaeval(printf('%s(_A[1], _A[2], _A[3])', matchstr(a:func, '^v:lua\.\zs.*')), a:000)
  endif
  return nvim_call_function(a:func, a:000)
endfunction


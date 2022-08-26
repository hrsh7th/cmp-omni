function! luaomni#exec(fun_name, findstart, base)
  execute(printf('let result = %s(%d, "%s")',
        \ a:fun_name, a:findstart, escape(a:base, "'\"")))

  return result
endfunction

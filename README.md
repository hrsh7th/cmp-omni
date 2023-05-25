# cmp-omni

nvim-cmp source for omnifunc.

# Setup

```lua
require'cmp'.setup {
  sources = {
    {
      name = 'omni',
      option = {
        disable_omnifuncs = { 'v:lua.vim.lsp.omnifunc' }
      }
    }
  }
}
```

# Option

### disable_omnifuncs: string[]
default: `{ 'v:lua.vim.lsp.omnifunc' }`

The list of omnifunc names that should be disabled.


# Warning

If omnifunc is slow, your neovim will be slow down too.


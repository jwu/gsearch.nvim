# gsearch.nvim

A Neovim 0.11+ global-search plugin, ported from the `gsearch` feature in
[jwu/exvim-lite](https://github.com/jwu/exvim-lite).

## Requirements

- Neovim 0.11+
- [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) on `$PATH`

Run `:checkhealth gsearch` to verify ripgrep.

## Usage

The plugin works without `setup()`. Searches use Neovim's current working
directory and ripgrep with smart case, hidden files, and ignored files included.

```vim
:GS pattern
:GSearchCWord
```

`GS` is retained for compatibility with exvim-lite. This plugin intentionally
does not load `.exvim/config.json` or change the current working directory.

### Results window

`GS` opens a bottom split named `[GSearch Results]`. Its buffer-local mappings
are:

| Key | Action |
| --- | --- |
| `<F1>` | Toggle help |
| `<Esc>` | Close results |
| `<Space>` | Toggle normal/zoomed height |
| `<CR>` / double-click | Open the selected result, then return to results |
| `<S-CR>` / Shift-double-click | Open the selected result in a preview window |
| `<leader>r` / `<leader>fr` | Keep results matching the `/` register in text / file name |
| `<leader>d` / `<leader>fd` | Remove results matching the `/` register in text / file name |

The results buffer also provides `:R`, `:FR`, `:D`, and `:FD`, each taking one
Vim regular expression. They have the same text/file and keep/remove behavior
as the mappings above.

Small result sets are sorted by file path and line number. Selecting a result
uses its recorded text to relocate the cursor if the file changed after the
search. When [win-buf-op.nvim](https://github.com/jwu/win-buf-op.nvim) is
installed, Gsearch opens the result in its recorded last editing window;
otherwise it uses the first current window with an empty `buftype`.

## Configuration

`setup()` is optional:

```lua
require('gsearch').setup({
  win_size = 15,
  win_size_zoom = 40,
  win_pos = 'bottom', -- 'top' is also supported
  enable_sort = true,
  sort_lines_threshold = 100,
  globs = "-g '*.lua' -g '!vendor/**'",
})
```

For exvim-lite compatibility, these globals work without `setup()`:

```lua
vim.g.ex_search_winsize = 15
vim.g.ex_search_winsize_zoom = 40
vim.g.ex_search_winpos = 'bottom'
vim.g.ex_search_enable_sort = 1
vim.g.ex_search_sort_lines_threshold = 100
vim.g.ex_search_globs = "-g '*.lua' -g '!vendor/**'"
```

`globs` and `g:ex_search_globs` are appended verbatim to the `rg` command, so
only use trusted ripgrep arguments.

## Lua API

```lua
local gsearch = require('gsearch')
gsearch.setup({ win_pos = 'top' })
gsearch.search('pattern')
gsearch.search_cword()
gsearch.open()
gsearch.toggle()
gsearch.close()
```

## Development

```sh
just check
```

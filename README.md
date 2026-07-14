# gsearch.nvim

A Neovim plugin for searching the current working directory with ripgrep and
reviewing results in a persistent split.

## Features

- Smart-case ripgrep searches from Neovim's current working directory
- Hidden files included in searches
- One project-local ignore file, selected in this order: `.rgignore`,
  `.ignore`, `.gitignore`
- Persistent results split with filtering, result previews, and result opening
- Optional sorting of small result sets by file path and line number
- Optional configuration through `require('gsearch').setup()`
- `:checkhealth gsearch` support

## Requirements

- Neovim 0.11+
- [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) on `$PATH`

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'jwu/gsearch.nvim',
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use { 'jwu/gsearch.nvim' }
```

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'jwu/gsearch.nvim'
```

## Usage

Gsearch works without calling `setup()`.

```vim
:GS pattern
:GSearchCWord
```

Commands:

- `:GS {pattern}`: search for `{pattern}`.
- `:GSearchCWord`: search for the word under the cursor.

Gsearch does not change the current working directory.

### Ignore files

Gsearch disables ripgrep's automatic ignore-file discovery. It checks only the
current working directory and passes one ignore file to ripgrep:

1. `.rgignore`
2. `.ignore`
3. `.gitignore`

The first existing file is the only ignore file used.

### Results window

A search opens a bottom split named `[GSearch Results]`. Its buffer-local
mappings are:

| Key | Action |
| --- | --- |
| `<F1>` | Toggle help |
| `<Esc>` | Close results |
| `<Space>` | Toggle normal/zoomed height |
| `<CR>` / double-click | Open the selected result, then return to results |
| `<S-CR>` / Shift-double-click | Open the selected result in a preview window |
| `<leader>r` / `<leader>fr` | Keep results matching the `/` register in text / file name |
| `<leader>d` / `<leader>fd` | Remove results matching the `/` register in text / file name |

The result buffer also provides these commands, each accepting one Vim regular
expression:

- `:R {pattern}` / `:FR {pattern}`: keep matching text / file names
- `:D {pattern}` / `:FD {pattern}`: remove matching text / file names

Small result sets are sorted by file path and line number. When opening a
result, Gsearch uses its recorded text to relocate the cursor if the file
changed after the search.

## Configuration

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

Options:

| Option | Default | Description |
| --- | --- | --- |
| `win_size` | `15` | Results window height |
| `win_size_zoom` | `40` | Results window height while zoomed |
| `win_pos` | `'bottom'` | Results window position; `'top'` is also supported |
| `enable_sort` | `true` | Sort small result sets |
| `sort_lines_threshold` | `100` | Largest result set that is sorted |
| `globs` | `''` | Extra ripgrep command arguments |

`globs` is appended verbatim to the ripgrep command. Only use trusted ripgrep
arguments.

### Highlight groups

Gsearch defines these highlight groups with a default link to `Visual`. Define
the groups after the plugin loads to override them:

```lua
vim.api.nvim_set_hl(0, 'GsearchConfirm', { link = 'Search' })
vim.api.nvim_set_hl(0, 'GsearchTarget', { bg = '#3b4252' })
```

| Group | Used for |
| --- | --- |
| `GsearchConfirm` | The selected result in the results window |
| `GsearchTarget` | The target line after opening or previewing a result |

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

## Health check

Run:

```vim
:checkhealth gsearch
```

## Development

Tests use [Busted](https://olivinelabs.com/busted/).

```sh
just check
```

## Documentation

See `:help gsearch` for full vimdoc.

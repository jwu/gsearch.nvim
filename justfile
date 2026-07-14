lua_dirs := 'lua plugin tests'

_default:
  @just --list

fmt:
  @command -v stylua >/dev/null || { echo 'stylua is required'; exit 127; }
  stylua {{lua_dirs}}

fmt-check:
  @command -v stylua >/dev/null || { echo 'stylua is required'; exit 127; }
  stylua --check {{lua_dirs}}

typecheck:
  @command -v nvim >/dev/null || { echo 'nvim is required'; exit 127; }
  lua_language_server="${LUA_LANGUAGE_SERVER:-$(command -v lua-language-server || printf '%s' "$HOME/.local/share/nvim/mason/bin/lua-language-server")}"; [ -x "$lua_language_server" ] || { echo 'lua-language-server is required'; exit 127; }; logpath="$(mktemp -d)"; trap 'rm -rf "$logpath"' EXIT; VIMRUNTIME="$(nvim --clean --headless '+lua io.stdout:write(vim.env.VIMRUNTIME)' +qa)" "$lua_language_server" --check=. --checklevel=Warning --logpath="$logpath"

lint: typecheck
  @command -v selene >/dev/null || { echo 'selene is required'; exit 127; }
  selene {{lua_dirs}}
  lua -e "assert(loadfile('lua/gsearch/init.lua')); assert(loadfile('plugin/gsearch.lua'))"

test:
  busted tests

check: fmt-check lint test

# Neovim plugin best practices

## Public surface

- Keep initialization separate from configuration. A plugin should work without
  requiring `setup()` unless its behavior inherently needs configuration.
- Keep commands in a scoped namespace and use subcommands rather than many
  globals.
- Expose `<Plug>` mappings for user-selected keybindings; do not add default
  mappings without an explicit product decision.
- Treat commands, mappings, configuration, and Lua APIs as compatibility
  contracts once released.

## Loading and implementation

- Keep `plugin/` startup work minimal.
- Defer `require()` calls from commands, mappings, autocmds, and callbacks.
- Prefer small modules with explicit responsibilities.
- Use Lua 5.1-compatible APIs unless LuaJIT-specific behavior is explicitly
  required and documented.

## Configuration

- Use LuaCATS annotations for option and resolved configuration types.
- Merge user options with defaults using `vim.tbl_deep_extend` when appropriate.
- Validate public configuration with `vim.validate`.

## Health, documentation, and tests

- Add `lua/gsearch/health.lua` for runtime dependencies or configuration.
- Keep `README.md` and `doc/gsearch.txt` synchronized with all user-visible
  behavior.
- Use Busted for tests; favor unit tests for logic and isolate Neovim API
  boundaries when practical.

## Tooling

- Format with StyLua.
- Lint with selene using the `vim` standard.
- Type-check public Lua APIs with lua-language-server and LuaCATS annotations.

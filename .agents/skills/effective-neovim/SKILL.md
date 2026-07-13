---
name: effective-neovim
description: "This skill SHOULD be used when writing, reviewing, or refactoring Neovim plugins in Lua. Apply Neovim community best practices, plugin architecture patterns, and idiomatic Lua style to ensure clean, maintainable plugins."
---

# Effective Neovim

Apply Neovim community best practices when writing, reviewing, or refactoring Neovim plugins in Lua.

## Tooling

| Tool | Purpose |
|---|---|
| [StyLua](https://github.com/JohnnyMorganz/StyLua) | Formatter |
| [selene](https://kampfkarren.github.io/selene/) | Linter |
| lua-language-server | Type checking via LuaCATS annotations |

**Standard `.stylua.toml`:**

```toml
column_width = 100
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferSingle"
```

## Key principles

- Do not force `setup()`; separate configuration from initialization.
- Provide `<Plug>` mappings instead of imposing default keymaps.
- Prefer one scoped user command with subcommands.
- Defer `require()` calls from startup paths to callbacks.
- Use LuaCATS annotations for public APIs and configuration.
- Use Busted tests rather than plenary.nvim.
- Provide `lua/gsearch/health.lua` for `:checkhealth gsearch` when applicable.
- Document user-facing behavior in both the README and Vim help.

## Style conventions

- 2-space indentation; no tabs or semicolons.
- Prefer single quotes and a 100-column limit.
- Use `snake_case` for functions and variables.
- Use trailing commas in multi-line tables.
- Comment the reason, not the obvious implementation.

## Plugin structure

```
gsearch.nvim/
├── lua/gsearch/
│   ├── init.lua
│   ├── health.lua
│   └── *.lua
├── plugin/gsearch.lua
├── doc/gsearch.txt
└── tests/*_spec.lua
```

## References

Read [Neovim best practices](references/nvim-best-practices.md) before making
architecture, API, command, mapping, configuration, health-check, or testing
decisions.

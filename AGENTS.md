# AGENTS.md

## Project

This repository is `gsearch.nvim`, a Neovim plugin written in Lua.

The plugin targets:

- Neovim 0.11+
- Lua plugin conventions for Neovim
- a small, focused public API with opt-in configuration

The product behavior has not been specified yet. Do not infer search sources,
matching semantics, commands, mappings, UI, or dependencies from the project
name alone.

## Key structure

- `plugin/gsearch.lua` — auto-loaded entry point; add commands, autocmds, and
  `<Plug>` mappings here when needed
- `lua/gsearch/init.lua` — public Lua API surface
- `lua/gsearch/` — implementation modules
- `lua/gsearch/health.lua` — `:checkhealth gsearch` integration
- `doc/gsearch.txt` — Vim help; keep in sync with user-visible behavior
- `tests/` — Busted tests
- `.agents/skills/effective-neovim/` — local Neovim development guidance

## Working rules

- Use 2 spaces for indentation.
- Keep plugin startup light and defer `require()` calls from commands/autocmd callbacks.
- Do not force users to call `setup()` for basic functionality.
- Prefer `<Plug>` mappings over automatic default mappings.
- Prefer one scoped user command with subcommands over several global commands.
- Use LuaCATS annotations for public APIs and configuration.
- Add or update Busted tests with implementation changes.
- When user-visible behavior changes, update both `README.md` and `doc/gsearch.txt`.
- Keep the health check aligned with runtime dependencies and configuration.

## Commands

```sh
just fmt
just lint
just test
just check
```

## Safety / ask first

Ask before:

- defining search sources, matching, ranking, acceptance, or UI semantics
- adding default mappings, commands, or popup behavior
- introducing runtime dependencies
- choosing or changing public APIs and compatibility guarantees
- performing unrelated large refactors

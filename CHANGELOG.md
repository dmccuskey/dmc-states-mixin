# Changelog

## 0.2.0 (2026-09-29)

### Changed

- The state machine is now lua-states-mixin 1.4.0's, from DMC-Lua-Library's `lib.dmc_lua.lua_states_mix`: `require 'dmc_corona.dmc_states_mix'` returns a copy of it, so the shared module is left as it is. From lua-states-mixin 1.4.0:
  - A refused or failed move leaves the state stack as it was (`gotoState()` pushed before asking, `gotoPreviousState()` popped before asking).
  - No leaked globals (`_patch`, `outStr`, `errStr`).
  - `StatesMix.patch( obj )` works; `__undoInit__()` removes the states instead of resetting them.
  - An optional stack limit, `setStateStackLimit()`.
  - The rest are in lua-states-mixin's [Known Issues](https://github.com/dmccuskey/lua-states-mixin#known-issues).
- Rebuilt with dmc-corona-boot 1.6.0 and the current DMC-Lua-Library.

### Added

- `VERSION` in the table the module returns.
- Unit tests: `tests/run_unit.sh`, plain Lua 5.1.

### Removed

- The copy of `Utils.extend()`, which set the global `_extend`; the module uses DMC-Lua-Library's `lua_utils`.

## 0.1.0

- First release: lua-states-mixin packaged for Solar2D.

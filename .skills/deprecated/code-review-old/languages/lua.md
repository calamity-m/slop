# Lua Language Lens

Review Lua for nil-safety, global leakage, error-handling discipline, and table-sharing hazards. When the code is Neovim configuration or plugins, apply the Neovim section as well.

## Nil Safety and Truthiness

- `nil` and `false` are the only falsy values; `0` and `""` are truthy. Flag conditions that assume C-like truthiness (`if count then` intended as `if count ~= 0 then`).
- Flag indexing into a chain (`a.b.c`) where any intermediate can be nil — one missing key raises "attempt to index a nil value" at runtime. Suggest guards or a default table.
- `x = cond and a or b` returns `b` whenever `a` is `false` or `nil` — flag this idiom when `a` can legitimately be falsy.
- Flag `#tbl` on tables that may have nil holes; the length operator is undefined over holes. Sequences with possible gaps need explicit counts or `vim.tbl_count`-style helpers.
- Flag `ipairs` on a table where a nil element would silently truncate iteration mid-list.

## Scope and Global Leakage

- Every variable should be `local` unless a global is deliberate. Flag any assignment without `local` that isn't an intentional, documented global — a missing `local` inside a function silently pollutes `_G` and survives across calls.
- Flag loop or callback variables shadowing an outer local with the same name when both are used nearby — a classic source of "why didn't it update" bugs.
- Modules should return a table (`local M = {} ... return M`), not write globals as their interface. Flag module files with side effects on `_G`.

## Error Handling

- Flag `pcall` whose boolean result is discarded — `pcall(fn)` alone converts an error into silent success.
- Flag error paths that return `nil` without the conventional second value (`return nil, "reason"`); callers can't distinguish "absent" from "failed".
- `error()` with a table or non-string loses information through default handlers — flag unless a matching `pcall` handler consumes it.
- Flag broad `pcall` wrappers around large blocks where only one call can actually fail; they hide unrelated bugs.

## Table Sharing and Mutation

- Tables are references. Flag a table literal defined once (e.g. a default-options table at module level) and then mutated per call — every caller shares the mutation. Copy or construct fresh per use.
- Flag in-place mutation of a table received as an argument when the caller plausibly reuses it.
- Flag naive shallow copies where nested tables still alias the original; deep-extend or explicit deep copy is needed when nested values are modified.

## Neovim-Specific

- Flag `vim.tbl_deep_extend` used to merge list-like values — it merges by numeric key rather than replacing the list. Lists that must be replaced need a function override or explicit assignment.
- Flag keymaps defined via `vim.keymap.set` with no `desc` — undiscoverable in `which-key`/`:map` listings. Match the sibling convention.
- Flag autocmds created without a named group (`vim.api.nvim_create_augroup` with `clear = true`); on config reload they stack up and fire multiple times.
- Flag `vim.api` calls in contexts where the API is restricted (inside `vim.schedule`-requiring fast events, e.g. some autocmd and libuv callbacks) without `vim.schedule`/`vim.schedule_wrap`.
- Flag top-level `require` of heavy plugin modules in startup-path config when the surrounding code lazy-loads; match the loading pattern the siblings use.
- Flag hardcoded machine-specific paths or values where the codebase has an established local-override mechanism (e.g. optional `require` of an ignored local module).

## Good Findings

- `local opts = { ... }` at module level, mutated inside a function called per buffer — state bleeds across buffers
- `if timeout then` treating a configured `timeout = 0` as enabled
- `pcall(require, "plugin")` with the result unused, so a broken plugin fails silently
- An assignment `result = compute()` missing `local`, leaking a global that masks a later bug
- `vim.tbl_deep_extend("force", defaults, user_opts)` where `user_opts.sections` is a list the user expects to replace, not merge
- An autocmd registered in a config file without an augroup, duplicating on every `:source`

## Weak Findings to Avoid

- Demanding LuaDoc annotations on trivial keymap or plugin-setup one-liners where name plus `desc` already communicates intent
- Flagging globals that are the platform's documented interface (`vim`, `_G.P` style debug helpers the codebase established deliberately)
- Micro-optimizations like localizing library functions (`local insert = table.insert`) outside genuinely hot loops
- Flagging `pcall(require, ...)` guards around optional modules when the fallback behavior is explicit and intended

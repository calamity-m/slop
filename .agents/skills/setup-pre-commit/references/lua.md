# Lua hooks

## Detection

Files matching `**/*.lua`, or presence of a Neovim config directory (`nvim/`).

## Hooks

Use `repo = "local"` to invoke a system-installed `stylua` directly — no third-party repo required.

```toml
[[repos]]
repo = "local"

[[repos.hooks]]
id = "stylua"
name = "stylua"
entry = "stylua --check"
language = "system"
types = ["lua"]
```

## Notes

- Requires `stylua` on PATH. Install via `cargo install stylua` or your system package manager.
- `--check` exits non-zero if files would change without modifying them. The developer runs `stylua .` manually to fix.
- StyLua reads `stylua.toml` or `.stylua.toml` in the repo root for formatting preferences (indent width, quote style, etc.). If neither exists and the project has strong style conventions, create a minimal one before adding the hook.
- If no config file is present, StyLua uses its defaults (2-space indent, double quotes).

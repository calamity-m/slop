# slop

Personal dotfiles for Neovim, Bash, Zellij, mise, Peanutbutter snippets, and reusable AI-agent skills, installed by symlinking this repo into `$HOME`.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State assumptions explicitly when they affect the change.
- If multiple interpretations exist, present them instead of picking silently.
- If a simpler approach exists, say so. Push back when warranted.
- Do not expand into adjacent setup, rewiring, cleanup, or integrations that were not requested.
- If something is unclear enough to risk the result, stop, name what's confusing, and ask.

## 2. Guidelines

- Treat `install.sh` as the contract for what this repo installs. When adding or moving a dotfile area, update symlink setup, usage text, and final summary lines together.
- Keep `install.sh` conservative: preserve `ensure_symlink` behavior where real files are skipped unless `--force` is passed.
- Touch only what the task needs. Do not refactor unrelated config, comments, keymaps, snippets, or formatting; mention unrelated stale config instead of deleting it.
- Do not bulk-format `.config/zellij/config.kdl`; `.config/nvim/lua/plugins/conform.lua` intentionally disables `kdlfmt` for that file.
- Respect `.gitignore`: local Neovim overrides live under `.config/nvim/lua/local/*.lua`, and only explicitly listed `.pi/agent/prompts/*.md` and `.bashrc.d/*.sh` files are tracked.
- Skills under `.agents/skills/*/SKILL.md` are executable agent instructions. Keep references relative to each skill directory and verify any referenced scripts or docs exist.

## 3. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Prefer concrete checks such as `bash -n install.sh`, loading the changed Neovim module, validating a snippet fixture, or running the relevant tool command.

Strong success criteria let you loop independently. Weak criteria require clarification.

## 4. In-Code Documentation

**Public API must be documented. Internal logic should explain the why.**

Use the native comment style for the file being edited: `---` LuaDoc for public Lua modules/functions, `#` comments for Bash and TOML, `//` comments for KDL, and concise Markdown notes in skill docs.

For public Lua and shell entry points:

- Document what the item is for and any non-obvious environment, filesystem, or external-command requirement.
- Keep one-liners for simple keymaps, aliases, and plugin setup; the name plus `desc` is often enough.

For internal code, comment the why, not the what:

- Symlink safety in `install.sh` (`--force`, skipped existing files, and `$CLAUDE_HOME`/`$CODEX_HOME` handling).
- Formatting exceptions such as Prettier requiring a project config and `kdlfmt` skipping Zellij `config.kdl`.
- Neovim/Zellij runtime coupling, especially pane renaming in `.config/nvim/lua/zellij.lua` and locked-mode keybind assumptions in `.config/zellij/config.kdl`.
- Mason versus mise ownership: Mason installs Neovim-scoped LSP/DAP/format tools, while mise installs shell-visible binaries.

## 5. Key Decisions

- `install.sh` is the only installer. Its `ensure_dir` and `ensure_symlink` functions create links into `~/.config`, `~/.agents`, `~/.pi/agent`, and tool-specific skill paths without replacing real files unless `--force` is used.
- Neovim starts at `.config/nvim/init.lua`, which loads `options`, `keymaps`, `plugins`, `theme`, then `require("zellij").setup()`. Plugin registration lives in `.config/nvim/lua/plugins.lua` via `vim.pack.add` and the ordered `plugin_modules` list.
- Mason state is centralized in `.config/nvim/lua/plugins/mason.lua`: `M.lsp_servers` feeds `vim.lsp.enable(mason.lsp_servers)` in `.config/nvim/lua/plugins/lsp.lua`, while `tools` feeds `mason-tool-installer`.
- Debugger setup lives in `.config/nvim/lua/plugins/dap.lua`; language-specific launch/test workflows live under `.config/nvim/lua/plugins/dap/`.
- Formatting is centralized in `.config/nvim/lua/plugins/conform.lua`; `format_on_save` is enabled, Prettier only runs when `has_prettier_config(ctx)` finds config, and `WriteNoFormat`/`ConformDir` are the escape hatches.
- Zellij integration is split: `.config/nvim/lua/zellij.lua` renames panes through `zellij action rename-pane`, while `.config/zellij/config.kdl` uses `clear-defaults=true`, `default_mode "locked"`, custom themes, and disabled `web_sharing`.
- `.agents/skills` and `.pi/agent/prompts` are distributed as dotfiles, not built artifacts; changes should be plain Markdown/YAML/shell that work after symlinking through `install.sh`.

## Repository Notes

- No repo pre-commit config is currently present. If adding one is in scope, natural checks are `bash -n` and `shellcheck` for `install.sh` and `.bashrc.d/*.sh`, plus `stylua` for `.config/nvim/**/*.lua`.
- `.config/mise/config.toml` is intentionally limited to global binary tools, not project language runtimes.
- Peanutbutter snippets live under `.config/peanutbutter/snippets`; keep snippet changes as Markdown sections with executable fenced code blocks and check syntax against the upstream Peanutbutter docs when needed.
- `CLAUDE.md` should remain a symlink to `AGENTS.md` so Claude Code and other agents read the same guidance.

**These guidelines are working if:** diffs stay small, assumptions are visible, and verification is concrete.

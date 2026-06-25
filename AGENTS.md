# slop

Personal dotfiles for Neovim, Bash, Zellij, mise, Peanutbutter snippets, and reusable AI-agent skills, installed by symlinking this repo into `$HOME`.

## 1. Project Rules

- Surface assumptions and tradeoffs before changing config behavior; this repo favors small, explicit dotfile changes over broad cleanup or unrelated refactors.
- Treat `install.sh` as the contract for what this repo installs. When adding or moving a dotfile area, update symlink setup, usage text, and final summary lines together.
- Keep `install.sh` conservative: preserve `ensure_symlink` behavior where real files are skipped unless `--force` is passed.
- Do not bulk-format `.config/zellij/config.kdl`; `.config/nvim/lua/plugins/conform.lua` intentionally disables `kdlfmt` for that file.
- Respect `.gitignore`: local Neovim overrides live under `.config/nvim/lua/local/*.lua`, tracked prompts live under `.agents/prompts/*.md`, and only explicitly listed `.bashrc.d/*.sh` files are tracked.
- Skills under `.agents/skills/*/SKILL.md` are executable agent instructions. Keep references relative to each skill directory and verify any referenced scripts or docs exist.

## 2. Verification

Define success criteria before editing, then run the checks that match the changed area.

For multi-step tasks, state a brief plan with checks:

```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Useful checks in this repo:

- Installer changes: `bash -n install.sh`; if behavior changed, inspect `./install.sh --help` and keep usage text, symlink setup, and final summary in sync.
- Bash snippets: `bash -n .bashrc.d/<file>.sh`; use `shellcheck` when available.
- Neovim Lua: load the changed module with Neovim when practical, or run `stylua --check .config/nvim` when formatting is in scope.
- Zellij config: avoid whole-file formatting; validate only the touched KDL behavior manually or with the relevant Zellij command if available.
- Skill docs: confirm every relative reference from `.agents/skills/<skill>/SKILL.md` resolves from that skill directory.
- Peanutbutter snippets: keep Markdown sections with executable fenced blocks and validate against Peanutbutter behavior/docs when changing snippet syntax.

Strong success criteria let agents loop independently. Weak criteria require clarification.

## 3. In-Code Documentation

Use the native comment style for the file being edited: `---` LuaDoc for public Lua modules/functions, `#` comments for Bash and TOML, `//` comments for KDL, and concise Markdown notes in skill docs.

For public Lua and shell entry points:

- Document what the item is for and any non-obvious environment, filesystem, or external-command requirement.
- Keep one-liners for simple keymaps, aliases, and plugin setup; the name plus `desc` is often enough.

For internal code, comment the why, not the what:

- Symlink safety in `install.sh` (`--force`, skipped existing files, and `$CLAUDE_HOME`/`$CODEX_HOME` handling).
- Formatting exceptions such as Prettier requiring a project config and `kdlfmt` skipping Zellij `config.kdl`.
- Neovim/Zellij runtime coupling, especially pane renaming in `.config/nvim/lua/zellij.lua` and locked-mode keybind assumptions in `.config/zellij/config.kdl`.
- Mason versus mise ownership: Mason installs Neovim-scoped LSP/DAP/format tools, while mise installs shell-visible binaries.

## 4. Key Decisions

- `install.sh` is the only installer. Its `ensure_dir` and `ensure_symlink` functions create links into `~/.config`, `~/.agents`, `~/.pi/agent`, and tool-specific skill paths without replacing real files unless `--force` is used.
- Neovim starts at `.config/nvim/init.lua`, which loads `options`, `keymaps`, `plugins`, `theme`, then `require("zellij").setup()`. Plugin registration lives in `.config/nvim/lua/plugins.lua` via `vim.pack.add` and the ordered `plugin_modules` list.
- Mason state is centralized in `.config/nvim/lua/plugins/mason.lua`: `M.lsp_servers` feeds `vim.lsp.enable(mason.lsp_servers)` in `.config/nvim/lua/plugins/lsp.lua`, while `tools` feeds `mason-tool-installer`.
- Neovim plugin configs that need machine-specific values should load optional ignored overrides from `.config/nvim/lua/local/*.lua`; prefer `vim.tbl_deep_extend` for table overrides and a function override when lists such as plugin `views` must be replaced.
- Debugger setup lives in `.config/nvim/lua/plugins/dap.lua`; language-specific launch/test workflows live under `.config/nvim/lua/plugins/dap/`.
- Formatting is centralized in `.config/nvim/lua/plugins/conform.lua`; `format_on_save` is enabled, Prettier only runs when `has_prettier_config(ctx)` finds config, and `WriteNoFormat`/`ConformDir` are the escape hatches.
- Zellij integration is split: `.config/nvim/lua/zellij.lua` renames panes through `zellij action rename-pane`, while `.config/zellij/config.kdl` uses `clear-defaults=true`, `default_mode "locked"`, custom themes, and disabled `web_sharing`.
- `.agents/skills` and `.agents/prompts` are distributed as dotfiles, not built artifacts; changes should be plain Markdown/YAML/shell that work after symlinking through `install.sh`.

## 5. Local Notes

- No repo pre-commit config is currently present. If adding one is in scope, natural checks are `bash -n` and `shellcheck` for `install.sh` and `.bashrc.d/*.sh`, plus `stylua --check .config/nvim` for Lua.
- `.config/mise/config.toml` is intentionally limited to global binary tools, not project language runtimes.
- Peanutbutter snippets live under `.config/peanutbutter/snippets`; keep snippet changes as Markdown sections with executable fenced code blocks and check syntax against the upstream Peanutbutter docs when needed.
- `CLAUDE.md` should remain a symlink to `AGENTS.md` so Claude Code and other agents read the same guidance.

**These guidelines are working if:** diffs stay small, assumptions are visible, and verification is concrete.

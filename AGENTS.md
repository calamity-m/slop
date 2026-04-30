# Agent Instructions

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State assumptions explicitly when they affect the change.
- If multiple interpretations exist, present them instead of picking silently.
- If a simpler approach exists, say so.
- Do not expand into adjacent setup, rewiring, or cleanup that was not requested.
- If something is unclear enough to risk the result, ask before editing.

## 2. Simplicity First

**Minimum change that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No configurability that was not requested.
- If a change starts getting large, stop and simplify before continuing.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing files:
- Do not refactor unrelated code, comments, or formatting.
- Match the existing style, even if you would write new code differently.
- If you notice unrelated dead code or stale config, mention it instead of deleting it.
- Remove only imports, variables, functions, or files made unused by your change.

Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

For multi-step tasks, state a brief plan:

```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Prefer concrete checks such as `bash -n install.sh`, loading a snippet file, or running the relevant command with a tiny fixture.

## 5. In-Code Documentation

**Explain why, not what.**

- For Bash functions and non-obvious shell blocks, add short comments only when they clarify intent, constraints, or side effects.
- For Lua config, document public helper functions or surprising setup decisions with concise Lua comments.
- Markdown snippets and runbooks should stay command-focused and avoid prose that repeats the command.
- Do not comment self-evident code.

## 6. Pre-commit Hooks

**Prefer repeatable checks over reminders.**

No repo pre-commit config is currently present. When adding one is in scope, prefer hooks that match this repo's files, such as shell syntax checks for `.sh` files and formatting/linting for Lua or Markdown where tooling already exists.

## 7. Project-Specific Notes

**Specifics every person should know when working on this project.**

- This is a dotfiles repo installed by `install.sh` via symlinks into home-directory config paths.
- Keep snippet changes in `.config/peanutbutter/snippets` as Markdown `##` sections with one executable fenced code block.
- When adding or editing Peanutbutter snippets, refer to https://github.com/calamity-m/peanutbutter/blob/main/docs/SNIPPET_SYNTAX.md.
- Shell aliases and helpers live in `.bashrc.d`; keep them POSIX-aware only where the surrounding file already is.
- Neovim config lives under `.config/nvim` and is Lua-based.

---

**These guidelines are working if:** diffs stay small, assumptions are visible, and verification is concrete.

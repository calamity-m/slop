---
name: setup-pre-commit
description: setup pre-commit hooks
---

# setup-pre-commit

Sets up `prek` pre-commit hooks in a repository. Handles fresh installs and enhancing existing configs.

Trigger this skill when:
- Asked to set up pre-commit hooks
- A CLAUDE.md instruction says to add a pre-commit hook for a task being done repeatedly (e.g. "add a hook for X")
- The user asks to add a specific check to existing hooks

## Step 1 — Validate prek is installed

```bash
prek --version
```

If the command fails, ask the user before doing anything else:

> `prek` isn't installed. Should I install it via `uv tool install prek`, or stop here?

If they say stop, stop. If yes, run `uv tool install prek` and confirm it succeeds before continuing.

## Step 2 — Detect mode

Check the repo root for an existing config:

```bash
ls prek.toml .pre-commit-config.yaml 2>/dev/null
```

- **Config found → enhance mode** (jump to [Enhance existing config](#enhance-existing-config))
- **No config → fresh setup** (continue to Step 3)

## Step 3 — Fresh setup

### Detect repo contents

Scan for languages present to select relevant hooks:

```bash
find . -not -path "./.git/*" \( -name "*.sh" -o -name "*.py" -o -name "*.lua" -o -name "*.rs" -o -name "*.go" -o -name "*.ts" -o -name "*.tsx" -o -name "*.java" \) | head -30
```

Also check for `Cargo.toml`, `go.mod`, `package.json`, `pom.xml`, `build.gradle` to confirm language presence.

For each language found, read the matching reference file before writing any hook blocks:

| Language / files found | Reference file |
|---|---|
| `.py`, `pyproject.toml`, `requirements.txt` | `references/python.md` |
| `.java`, `pom.xml`, `build.gradle` | `references/java.md` |
| `.rs`, `Cargo.toml` | `references/rust.md` |
| `.go`, `go.mod` | `references/go.md` |
| `.tsx`, `.jsx`, `react` in `package.json` | `references/react.md` |
| `.ts`, `tsconfig.json` (no React) | `references/typescript.md` |
| `.sh` | `references/shell.md` |
| `.lua` | `references/lua.md` |

### Resolve latest hook revisions

For each external repo you'll use, fetch the latest tag rather than hardcoding a version:

```bash
git ls-remote --tags --sort=-version:refname <repo-url> | awk -F/ 'NR==1{print $NF}'
```

Run this for each external repo before writing the config.

### Assemble prek.toml

Start with the universal built-ins, then append language-specific blocks from the reference files.

**Always include — built-ins (no version needed):**

```toml
[[repos]]
repo = "builtin"
hooks = [
    { id = "trailing-whitespace" },
    { id = "end-of-file-fixer" },
    { id = "check-merge-conflict" },
    { id = "detect-private-key" },
    { id = "check-added-large-files" },
]
```

For all languages — use the hook blocks from the relevant reference file.

Write the assembled file to `prek.toml` in the repo root.

### Install

```bash
prek install --install-hooks
```

Verify exit code 0 and that `.git/hooks/pre-commit` exists.

## Enhance existing config

Read the current config fully. Identify which hooks are already present. Then:

1. Scan the repo for languages (same `find` as above).
2. Read the relevant reference files for any detected languages.
3. Check whether any defaults from those references are missing given what's already configured.
4. Show the user a summary of what you'd add before touching anything.
5. Only after confirmation: append the new blocks and re-run `prek install --install-hooks`.

Do not remove, reorder, or modify existing hooks.

## Finish

Tell the user:
- What config file was written or updated
- Which hooks were added and what they check
- How to run manually: `prek run` (staged files) or `prek run -a` (all files)

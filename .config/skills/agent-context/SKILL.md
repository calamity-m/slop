---
name: agent-context
description: Create, bootstrap, curate, and compress repository-local agent instructions centered on `AGENTS.md`, plus `CLAUDE.md` and `GEMINI.md` aliases. Use when Codex needs to add agent context to a repo that lacks `AGENTS.md`, improve or rewrite an existing `AGENTS.md`, or derive durable repo guidance from conversation history and repo inspection.
---

# Agent Context

Keep one canonical `AGENTS.md` that tells coding agents how to work in this repository. Treat `CLAUDE.md` and `GEMINI.md` as aliases, not separate sources of truth.

## Route First

1. Inspect the repo root for `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and the overall repository shape.
2. If `AGENTS.md` does not exist:
   - If the repository is brand new or nearly empty, read [references/new-repo-bootstrap.md](./references/new-repo-bootstrap.md).
   - If the repository already contains real source, config, or build files, read [references/create-agents-in-existing-repo.md](./references/create-agents-in-existing-repo.md).
3. If `AGENTS.md` exists, read [references/curate-existing-agents.md](./references/curate-existing-agents.md).
4. If the current thread includes repeated corrections, stable preferences, or repo-specific lessons worth preserving, read [references/conversation-learnings.md](./references/conversation-learnings.md).
5. Before finishing, use [references/agents-best-practices.md](./references/agents-best-practices.md) as the quality bar.

## Core Rules

- Keep `AGENTS.md` as the source of truth.
- Prefer symlinks for `CLAUDE.md` and `GEMINI.md` instead of duplicate instruction files.
- Read the repository before asking questions that can be answered from files, manifests, docs, CI, or scripts.
- Keep `AGENTS.md` operational: setup, validate, test, lint, build, risky operations, and local conventions.
- Move long-lived architectural or pattern detail into repo docs and link to them from `AGENTS.md`.
- Do not replace an existing non-symlink instruction file without reading it and deciding deliberately.
- Only keep durable, repo-specific, action-guiding learnings. Omit one-off task context.

## Resources

### scripts/

- `scripts/init-repo.sh`: create `AGENTS.md` from the bundled template when missing, then add `CLAUDE.md` and `GEMINI.md` symlinks without overwriting conflicting files unless `--force` is used.

### assets/

- `assets/AGENTS.md.template`: starter `AGENTS.md` structure for the bootstrap paths.

### references/

- `references/new-repo-bootstrap.md`: how to bootstrap agent context in a brand new repository.
- `references/create-agents-in-existing-repo.md`: how to create `AGENTS.md` in an existing codebase that does not have one yet.
- `references/curate-existing-agents.md`: how to audit, compress, and improve an existing `AGENTS.md`.
- `references/conversation-learnings.md`: how to derive durable instructions from the current thread and merge them safely.
- `references/agents-best-practices.md`: quality bar for what belongs in `AGENTS.md` and what should live elsewhere.

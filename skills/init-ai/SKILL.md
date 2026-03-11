---
name: init-ai
description: Initialize a repository for shared AI-agent use by creating a canonical `AGENTS.md`, a shared `.skills/` directory, and tool-specific symlinks such as `CLAUDE.md`, `GEMINI.md`, `.claude/skills`, and `.codex/skills`. Use this skill when the user asks to bootstrap agent instructions in a repo, centralize per-tool prompts, add shared skill directories, or wire local agent files like `agents/grug-brain.md` into tool-specific agent folders.
---

# Init AI

Initialize repos around one source of truth instead of copying the same instructions into several tool-specific files.

Prefer safe, reversible setup: create shared files and symlinks, but do not silently replace real files or directories that already contain user-authored content.

## Workflow

1. Inspect the repo root for existing `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.skills/`, `agents/`, `.claude/`, `.codex/`, `.gemini/`, and `.opencode/`.
2. If instruction files already exist, read them before changing anything. Merge useful guidance into `AGENTS.md` instead of overwriting it.
3. Find the repository's docs location. Prefer an existing docs repository or shared docs directory when the repo already has one; otherwise create `docs/`.
4. Store durable repo context in human-readable docs such as `docs/ARCHITECTURE.md`, `docs/COMMON_PATTERNS.md`, and other focused files when needed.
5. Create or update `AGENTS.md` as the canonical instruction file. Keep it short, repo-specific, and operational, and point readers at the docs files instead of duplicating long-form context there.
6. Run `./scripts/init-repo.sh [repo-root]` from this skill directory to create the shared directories and symlinks.
7. If the script created `AGENTS.md` from the template, replace the placeholders with real repo commands, validation steps, conventions, and links to the docs files before finishing.
8. Ensure the docs files are useful to both agents and humans: enough context to understand the repository, current architecture, and normal working patterns without assuming hidden tribal knowledge.
9. If the repo has a shared `agents/` directory, verify that tool-specific agent directories point at it and mention that this is best-effort because agent loading behavior is tool-specific.
10. Report what was created, what was linked, and what was skipped because of conflicts.

## Rules

- Treat `AGENTS.md` as the source of truth.
- Treat `AGENTS.md` as the entrypoint, not the entire knowledge base.
- Prefer symlinks over duplicate copies for tool aliases and shared skill directories.
- Keep `AGENTS.md` focused on concrete repo behavior: setup, test, lint, build, validation, risky operations, and local conventions.
- Put durable repository context in `docs/` files such as `docs/ARCHITECTURE.md` and `docs/COMMON_PATTERNS.md`.
- When no docs location exists, default to creating `docs/`.
- Write docs for humans first and agents second: they should be clear, direct, and sufficient for a new contributor to understand how the repo works.
- Do not replace an existing non-symlink file or directory unless the user explicitly wants that migration.
- Use relative symlinks so the repo remains portable when moved.
- If agent directory aliases are created, call them best-effort and verify them in practice before claiming the tool will load them automatically.

## Canonical Layout

- `AGENTS.md`: shared instructions for all local coding agents.
- `docs/ARCHITECTURE.md`: repository architecture, major subsystems, boundaries, and data flow.
- `docs/COMMON_PATTERNS.md`: repeated implementation patterns, conventions, and examples worth reusing.
- `CLAUDE.md`, `GEMINI.md`, `CLAUDE.MD`, `GEMINI.MD`: symlinks to `AGENTS.md`.
- `.skills/`: shared skill directory owned by the repo.
- `.claude/skills`, `.codex/skills`, `.gemini/skills`, `.opencode/skills`: symlinks to `../.skills`.
- `agents/`: optional shared agent definitions such as `agents/grug-brain.md`.
- `.claude/agents`, `.codex/agents`, `.gemini/agents`, `.opencode/agents`: best-effort symlinks to `../agents` when `agents/` exists.

For `AGENTS.md` structure and aliasing guidance, read [references/agents-best-practices.md](./references/agents-best-practices.md).

## Resources

### scripts/

- `scripts/init-repo.sh`: create `AGENTS.md` from the template when needed, create `.skills/`, and add the tool-specific symlinks without overwriting conflicting paths unless `--force` is used.

### assets/

- `assets/AGENTS.md.template`: starter `AGENTS.md` skeleton with the sections that should be filled in using repo-specific facts.

### references/

- `references/agents-best-practices.md`: what belongs in `AGENTS.md`, what should stay out, and how to treat skill and agent aliases conservatively.

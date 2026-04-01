# Curate An Existing AGENTS.md

Use this path when the repository already has `AGENTS.md`.

## Goal

Keep `AGENTS.md` short, accurate, repo-specific, and aligned with how the codebase actually works.

## Audit Pass

Check the existing file against the repository:

- Do the setup, validate, test, lint, and build commands still exist?
- Are risky operations called out correctly?
- Are there stale paths, tools, or workflows?
- Is the file bloated with generic guidance that does not help in this repo?
- Are there durable details that belong in docs instead of `AGENTS.md`?

## Workflow

1. Read the existing `AGENTS.md` before changing anything.
2. Inspect the repo sources of truth needed to confirm or reject each important instruction.
3. Preserve useful repo-specific guidance; remove stale or generic text.
4. Compress the file so the highest-value operational instructions are easy to scan.
5. If durable context is too long for `AGENTS.md`, move it into focused docs and link to them.
6. Normalize `CLAUDE.md` and `GEMINI.md` to alias `AGENTS.md` only when it is safe to do so.
7. If the current thread contains durable corrections or preferences, merge them using [conversation-learnings.md](./conversation-learnings.md).

## What To Preserve

- repo-specific commands
- genuine safety constraints
- local patterns that repeatedly save time or avoid breakage
- user-authored guidance that still matches reality

## What To Remove

- generic agent advice that is not repo-specific
- outdated commands or paths
- duplicated long-form architecture text
- one-off instructions tied to a single task

## Done When

- The file is more accurate and shorter or denser.
- Every retained instruction earns its space.
- The canonical/alias relationship is clear and safe.

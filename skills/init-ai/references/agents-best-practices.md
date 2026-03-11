# AGENTS.md Best Practices

Use `AGENTS.md` as the canonical repo-local instruction file.

Treat it as the front door, not the entire house.

## Keep It Operational

- Include real commands for setup, test, lint, build, formatting, and any narrow validation steps that agents should prefer.
- Call out risky operations explicitly: migrations, deploys, generated files, large refactors, or commands that should not be run automatically.
- Describe the repo's real layout and ownership boundaries only when that context changes how edits should be made.

## Put Long-Lived Context In Docs

- Find the repository's docs location first. If there is no existing docs location, create `docs/`.
- Put architecture context in `docs/ARCHITECTURE.md`.
- Put recurring implementation guidance in `docs/COMMON_PATTERNS.md`.
- Add more focused docs files only when the topic deserves its own page.
- Write doc files so a human can read them end to end and understand how to work in the repository.
- Do not bury all of that context inside `AGENTS.md`; link to the docs from `AGENTS.md` instead.

## Keep It Short

- Prefer a few useful sections over a long policy document.
- Cut generic advice that already exists in the agent harness.
- Replace placeholders with repo facts before considering the file done.

## Good Sections

- `Scope` or `Purpose`: what this repo is and what the instructions are optimizing for.
- `Commands`: exact commands for validation and local development.
- `Workflow`: expectations such as small diffs, targeted tests, or reading adjacent files before editing.
- `Conventions`: naming, formatting, generated files, migration policy, or module boundaries when those facts matter.

## Shared Layout

- Keep `AGENTS.md` as the source of truth.
- Point `CLAUDE.md`, `GEMINI.md`, and any casing variants at `AGENTS.md` with symlinks instead of duplicate copies.
- Keep shared reusable skills in `.skills/`.
- Point tool-specific skill folders such as `.claude/skills` and `.codex/skills` at `../.skills`.

## Agent Aliases

- If the repo has local agents in `agents/`, symlink tool-specific agent folders to that directory as a convenience.
- Treat agent directory symlinks as best-effort: the filesystem link may work while product support still varies by tool and version.
- If the repo relies on a specific agent definition such as `agents/grug-brain.md`, mention that in the final report and recommend verifying real tool pickup before depending on it.

## Conflict Policy

- Do not overwrite an existing instruction file or tool directory without reading it first.
- If a repo already has a real `.claude/skills` directory or a hand-written `CLAUDE.md`, merge deliberately instead of forcing a symlink by default.

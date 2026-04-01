# Create AGENTS.md In An Existing Repo

Use this path when the repository does not have `AGENTS.md`, but the codebase already exists.

## Goal

Create a high-signal `AGENTS.md` from the actual repository, not from guesses.

## Explore Before Asking

Inspect the likely sources of truth first:

- root manifests and lockfiles
- `README` and `docs/`
- CI workflows
- test runners, linters, formatters, and build scripts
- obvious entrypoints and major directories

Before asking the user anything, derive as much as possible from the codebase.

## Workflow

1. Inspect the repo to determine:
   - setup and validation commands
   - test, lint, and build commands
   - generated files or codegen entrypoints
   - dangerous operations such as deploys, migrations, or release scripts
   - architecture boundaries or repeated local patterns worth documenting
2. Run `./scripts/init-repo.sh [repo-root]` from this skill directory to create `AGENTS.md` and aliases when they are missing.
3. Replace the template with repo-specific instructions:
   - exact commands
   - high-value workflow expectations
   - conventions that matter for safe edits
4. If the repository needs more durable context than fits comfortably in `AGENTS.md`, create or update focused docs such as `docs/ARCHITECTURE.md` or `docs/COMMON_PATTERNS.md` and link them.
5. Ask the user only about high-impact product or workflow choices that cannot be derived from the repository.

## Quality Bar

- Keep the file short enough to scan quickly.
- Prefer exact commands over prose.
- Remove generic advice that the harness already provides.
- Do not claim a command is preferred unless the repo actually uses it.

## Done When

- `AGENTS.md` is grounded in the existing repo.
- Alias files point to `AGENTS.md` when safe.
- Open questions are limited to real product or policy ambiguity, not discoverable repo facts.

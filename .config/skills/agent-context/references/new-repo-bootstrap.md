# New Repo Bootstrap

Use this path when the repository has no `AGENTS.md` and little or no substantive code yet.

## Goal

Create a clean starting point:

- `AGENTS.md` as the canonical instruction file
- `CLAUDE.md` and `GEMINI.md` as aliases
- repo-specific commands and conventions filled in as far as the repository already supports

## Workflow

1. Inspect the repository before writing:
   - root files
   - manifests such as `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Makefile`
   - existing docs such as `README`, `docs/`, CI config
2. Run `./scripts/init-repo.sh [repo-root]` from this skill directory to create `AGENTS.md` and the two aliases.
3. Replace the template placeholders with real repository facts.
4. If the repository already has setup, validation, test, lint, or build commands, record them exactly.
5. If the repository is truly new and those commands do not exist yet, keep the file lean:
   - remove empty sections that cannot be grounded in reality
   - ask targeted questions only when the missing decision blocks a useful `AGENTS.md`
6. If durable architecture or pattern context already exists, point `AGENTS.md` at that docs location instead of duplicating it.

## What To Avoid

- Do not leave a wall of untouched template placeholders and call the job done.
- Do not invent commands, conventions, or stack details.
- Do not add long generic policy text that is not specific to the repository.

## Done When

- `AGENTS.md` exists and is the canonical entrypoint.
- `CLAUDE.md` and `GEMINI.md` point to `AGENTS.md` when safe.
- The file contains grounded repo instructions, not just template text.

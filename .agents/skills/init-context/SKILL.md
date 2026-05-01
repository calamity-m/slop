---
name: init-context
description: Create or update a repo `AGENTS.md` or `CLUADE.md` file with cautious implementation guidance. Use when the user wants to scaffold agent instructions around explicit assumptions, simplicity-first execution, surgical diffs, and verifiable success criteria.
---

# Init Context

Create or update a repository `AGENTS.md` file that tells coding agents to think before coding, keep changes minimal, and verify outcomes concretely. 

This skill is for scaffolding or refreshing the repo instruction file, not for applying the posture by itself.

## Workflow

1. Default the target file to `<repo-root>/AGENTS.md` unless the user specifies another path.
2. **Survey the repository** before writing anything — run a quick scan to determine:
   - Primary language(s) and build tooling (check file extensions, `Cargo.toml`, `package.json`, `pyproject.toml`, `go.mod`, etc.)
   - Existing linter/formatter/test tooling (CI config, `Makefile`, pre-commit config, lock files)
   - **Repository map inputs**: top-level directories worth naming, the file(s) where execution starts, and the dominant data flow. Open enough source files to back the map with real paths — do not guess.
   - Any domain context visible from directory structure or README
3. If `AGENTS.md` already exists, read it end-to-end before editing. If `CLAUDE.md` exists, treat that as the existing `AGENTS.md` file.
4. **Score the existing file** against [`references/quality-criteria.md`](references/quality-criteria.md) when one exists. The score determines the edit posture:
   - **≥ 85**: leave as-is or apply only what the user asked for.
   - **70–84**: targeted updates to the lowest-scoring sections.
   - **50–69**: substantial rewrite of weak sections, preserve anything strong.
   - **< 50**: surface the score to the user and propose a near-rewrite before doing it. Do not silently overwrite.
5. Read [`assets/AGENTS.template.md`](assets/AGENTS.template.md) as the structural source of truth, then **adapt it to the repo** before writing:
   - **In-Code Documentation**: mention only the doc format(s) relevant to the repo's language(s) — rustdoc for Rust, docstrings for Python, JSDoc for JS/TS, etc. Drop the others.
   - **Pre-commit Hooks**: name the actual tools the repo uses or would naturally adopt (e.g. `cargo clippy`, `ruff`, `eslint`, `golangci-lint`), not generic placeholders.
   - **Repository Map**: fill in key directories (path -> purpose), entry point(s) with launch command, and a short data-flow chain. Use real paths from the survey. If the repo is too small to need a map, write the one-line "Single script…" form instead of padding.
   - **Project-Specific Notes**: fill in real observations from the survey — domain rules, design decisions, non-obvious conventions. Leave the section empty or minimal if nothing meaningful is apparent; do not invent content.
6. If the file exists, preserve unrelated instructions and update only the sections that correspond to this guidance.
7. Keep the resulting `AGENTS.md` clean and direct. Do not add extra explanatory docs.
8. **Verify against the rubric** before declaring the task done — re-score the final file. If any criterion would still drop below its full weight, fix it before stopping.
9. Verify the final file contains all major sections and the short multi-step plan example.
10. Symlink `CLAUDE.md` to `AGENTS.md` if not already linked.

## Required Behavior

- Survey the repo before writing — the template is a structure, not a script to paste verbatim.
- Create `AGENTS.md` when it is missing.
- Update `AGENTS.md` surgically when it already exists.
- Preserve unrelated existing agent instructions unless the user asked to replace the file.
- Do not silently discard user-written guidance already present in `AGENTS.md`.
- Keep the scaffolding small: one file plus this skill's own metadata and template asset.

## Template Source

The canonical scaffold content lives in:

- [`assets/AGENTS.template.md`](assets/AGENTS.template.md)

Use it as the structure and prose baseline, but tailor the repo-specific sections (In-Code Documentation, Pre-commit Hooks, Project-Specific Notes) to what the survey found. Generic placeholder text is worse than a short accurate description.

For an existing `AGENTS.md`, prefer refactoring it to match the template structure with user confirmation. If the existing file conflicts with the template and the right merge is not obvious, surface the conflict instead of guessing.

## What To Verify

- `AGENTS.md` exists at the intended path.
- The file contains all major sections:
  - Think Before Coding
  - Simplicity First
  - Surgical Changes
  - Goal-Driven Execution
  - In-Code Documentation
  - Pre-commit Hooks
  - Repository Map (key directories, entry point(s), data flow)
  - Project-Specific Notes
- The file includes the short numbered verification-plan example.
- Every path and command in the Repository Map resolves against the actual repo.
- A final pass against [`references/quality-criteria.md`](references/quality-criteria.md) shows no criterion under its full weight that you can fix without speculation.
- No unrelated `AGENTS.md` content was removed unless the user asked for replacement.

## Example Triggers

- "Create an `AGENTS.md` with cautious coding guidance."
- "Scaffold repo agent instructions before we start coding."
- "Add a simplicity-first and verification-first section to `AGENTS.md`."
- "Update this repo's `AGENTS.md` with explicit assumptions and surgical diff rules."

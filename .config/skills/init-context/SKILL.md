---
name: init-context
description: Create or update a repo `AGENTS.md` or `CLUADE.md` file with cautious implementation guidance. Use when the user wants to scaffold agent instructions around explicit assumptions, simplicity-first execution, surgical diffs, and verifiable success criteria.
---

# Init Context

Create or update a repository `AGENTS.md` file that tells coding agents to think before coding, keep changes minimal, and verify outcomes concretely. 

This skill is for scaffolding or refreshing the repo instruction file, not for applying the posture by itself.

## Workflow

1. Default the target file to `<repo-root>/AGENTS.md` unless the user specifies another path.
2. If `AGENTS.md` already exists, read it before editing. If `CLAUDE.md` exists, treat that as the existing `AGENTS.md` file.
3. If the file does not exist, create it from [`assets/AGENTS.template.md`](assets/AGENTS.template.md).
4. If the file exists, preserve unrelated instructions and update only the section that corresponds to this guidance.
5. Use the template text as the source of truth for the caution, simplicity, surgical-change, and goal-driven sections.
6. Keep the resulting `AGENTS.md` clean and direct. Do not add extra explanatory docs.
7. Verify the final file contains all four principle sections and the short multi-step plan example.
8. Symlink CLAUDE.md to AGENTS.md if not already linked

## Required Behavior

- Create `AGENTS.md` when it is missing.
- Update `AGENTS.md` surgically when it already exists.
- Preserve unrelated existing agent instructions unless the user asked to replace the file.
- Do not silently discard user-written guidance already present in `AGENTS.md`.
- Keep the scaffolding small: one file plus this skill's own metadata and template asset.

## Template Source

The canonical scaffold content lives in:

- [`assets/AGENTS.template.md`](assets/AGENTS.template.md)

Copy it directly for a new file unless the user asks for changes.

For an existing `AGENTS.md`, prefer either:

- Refactoring the existing AGENTS.md, with confirmation of the user, to match the template.

If the existing file conflicts with the template and the right merge is not obvious, surface the conflict instead of guessing.

## What To Verify

- `AGENTS.md` exists at the intended path.
- The file contains all major sections:
  - Think Before Coding
  - Simplicity First
  - Surgical Changes
  - Goal-Driven Execution
  - Verifiable Automation
  - Project-Specific Notes
- The file includes the short numbered verification-plan example.
- No unrelated `AGENTS.md` content was removed unless the user asked for replacement.

## Example Triggers

- "Create an `AGENTS.md` with cautious coding guidance."
- "Scaffold repo agent instructions before we start coding."
- "Add a simplicity-first and verification-first section to `AGENTS.md`."
- "Update this repo's `AGENTS.md` with explicit assumptions and surgical diff rules."

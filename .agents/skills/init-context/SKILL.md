---
name: init-context
description: Create or update a repo `AGENTS.md` or `CLAUDE.md` file with project-specific implementation guidance. Use to scaffold agent instructions around repo rules, concrete verification, documentation norms, and key architectural decisions.
disable-model-invocation: true
---

# Init Context

Create or update a repository `AGENTS.md` file that tells coding agents what is specific to this project: rules, verification commands, documentation norms, and key decisions.

This skill is for scaffolding or refreshing the repo instruction file, not for applying the posture by itself. User-level context may already provide generic agent behavior, so avoid duplicating broad advice unless the project truly depends on it.

## Workflow

1. Default the target file to `<repo-root>/AGENTS.md` unless the user specifies another path.
2. **Survey the repository** before writing anything — run a quick scan to determine:
   - Primary language(s) and build tooling (check file extensions, `Cargo.toml`, `package.json`, `pyproject.toml`, `go.mod`, etc.)
   - The doc-comment format the language uses (rustdoc, docstrings, JSDoc, etc.) and the real invariants worth a `why` comment.
   - **Key Decisions inputs**: the handful of architectural facts that change how an agent works here — the central types, modules, entry points, and runtime model. Open enough source files to name them with real identifiers — do not guess.
   - Any domain context or project-specific rules visible from directory structure, README, or how the code is shaped.
3. If `AGENTS.md` already exists, read it end-to-end before editing. If `CLAUDE.md` exists, treat that as the existing `AGENTS.md` file.
4. **Score the existing file** against [`references/quality-criteria.md`](references/quality-criteria.md) when one exists. The score determines the edit posture:
   - **≥ 85**: leave as-is or apply only what the user asked for.
   - **70–84**: targeted updates to the lowest-scoring sections.
   - **50–69**: substantial rewrite of weak sections, preserve anything strong.
   - **< 50**: surface the score to the user and propose a near-rewrite before doing it. Do not silently overwrite.
5. Read [`assets/AGENTS.template.md`](assets/AGENTS.template.md) as the structural source of truth, then **adapt it to the repo** before writing. The template is a vibe, not a form to fill — open with the project's identity and keep the prose tight. The bar for every line: it is non-obvious, an agent would not cheaply discover it by searching, and it is specific enough that it cannot be misused as a shortcut to skip thinking. Cut anything that fails this — a thin, high-signal file beats a complete one.
   - **Header**: replace `# <project name>` and the one-line description with what this repo actually is and who it serves.
   - **Project Rules**: write 3-6 concrete, enforceable rules an agent keeps getting wrong here — not generic posture. Drop the placeholder examples; if nothing project-specific applies, keep the section short rather than padding it.
   - **Verification**: name concrete checks and commands for this repo. Keep the short multi-step plan example, but make surrounding guidance project-specific.
   - **In-Code Documentation**: mention only the doc format relevant to the repo's language(s) — rustdoc for Rust, docstrings for Python, JSDoc for JS/TS, etc. Name the repo's real invariants worth a `why` comment. Drop the others.
   - **Key Decisions**: name the real architectural facts — central types, modules, entry points, runtime model — using actual identifiers from the survey. Each line earns its place. If the repo is too small to have meaningful decisions, keep it to a line or two rather than inventing content.
6. If the file exists, preserve unrelated instructions and update only the sections that correspond to this guidance.
7. Keep the resulting `AGENTS.md` clean and direct. Do not add extra explanatory docs.
8. **Verify against the rubric** before declaring the task done — re-score the final file. If any criterion would still drop below its full weight, fix it before stopping.
9. Verify the final file leads with the project identity, contains all major sections, and keeps the short multi-step plan example.
10. Symlink `CLAUDE.md` to `AGENTS.md` if not already linked.

## Required Behavior

- Survey the repo before writing — the template is a structure, not a script to paste verbatim.
- Create `AGENTS.md` when it is missing.
- Update `AGENTS.md` surgically when it already exists.
- Preserve unrelated existing agent instructions unless the user asked to replace the file.
- Do not silently discard user-written guidance already present in `AGENTS.md`.
- Keep the scaffolding small: one project context file plus this skill's own metadata and template asset.

## Template Source

The canonical scaffold content lives in:

- [`assets/AGENTS.template.md`](assets/AGENTS.template.md)

Use it as the structure and prose baseline, but tailor the repo-specific sections (Project Rules, Verification, In-Code Documentation, Key Decisions) to what the survey found. The template's bracketed placeholders and example bullets are flavor cues — replace them with real content. Generic placeholder text is worse than a short accurate description.

For an existing `AGENTS.md`, prefer refactoring it to match the template structure with user confirmation. If the existing file conflicts with the template and the right merge is not obvious, surface the conflict instead of guessing.

## What To Verify

- `AGENTS.md` exists at the intended path.
- The file leads with the project name and a one-line description.
- The file contains all major sections:
  - Project Rules
  - Verification
  - In-Code Documentation
  - Key Decisions
- The file includes the short numbered verification-plan example.
- Every identifier named in Key Decisions resolves against the actual repo.
- A final pass against [`references/quality-criteria.md`](references/quality-criteria.md) shows no criterion under its full weight that you can fix without speculation.
- No unrelated `AGENTS.md` content was removed unless the user asked for replacement.

## Example Triggers

- "Create an `AGENTS.md` with cautious coding guidance."
- "Scaffold repo agent instructions before we start coding."
- "Add project-specific guidelines and a verification-first section to `AGENTS.md`."
- "Update this repo's `AGENTS.md` with explicit assumptions and the key architectural decisions."

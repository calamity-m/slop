---
name: init-context
description: Create or update a repo `AGENTS.md` or `CLAUDE.md` file with project-specific implementation guidance. Use to scaffold agent instructions around repo rules, concrete verification, documentation norms, and key architectural decisions.
disable-model-invocation: true
---

# Init Context

Create or update a repository `AGENTS.md` file that tells coding agents what is specific to this project: rules, verification commands, documentation norms, and key decisions.

This skill is for scaffolding or refreshing the repo instruction file, not for applying the posture by itself. User-level context may already provide generic agent behavior, so avoid duplicating broad advice unless the project truly depends on it.

## Workflow

1. Default the target file to `<repo-root>/AGENTS.md` unless the user specifies another path. In a monorepo, still default to the root; create nested per-package `AGENTS.md` files only when the user asks or the repo already uses them, and keep each one scoped to facts about its own directory.
2. **Survey the repository** before writing anything — run a quick scan to determine:
   - Primary language(s) and build tooling (check file extensions, `Cargo.toml`, `package.json`, `pyproject.toml`, `go.mod`, etc.)
   - **Verification inputs**: CI config (`.github/workflows`, `.gitlab-ci.yml`), `Makefile`/`justfile`, and manifest scripts (`package.json` scripts, cargo aliases). These are the best source of real, already-verified commands — prefer them over commands you construct yourself. Recent `git log` shows which areas actually churn and deserve rules.
   - Documentation conventions that refine or deviate from the language default (docstring style, what must be documented), and the real invariants worth a `why` comment.
   - **Key Decisions inputs**: the handful of architectural facts that change how an agent works here — the central types, modules, entry points, and runtime model. Open enough source files to name them with real identifiers — do not guess.
   - Any domain context or project-specific rules visible from directory structure, README, or how the code is shaped.
   - Other instruction files (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, etc.). If they conflict with each other or with `AGENTS.md`, flag the conflict to the user — do not silently reconcile.
3. Read [`assets/AGENTS.template.md`](assets/AGENTS.template.md). It is the structural source of truth, and the rubric's criteria refer to its sections. The template is a vibe, not a form to fill — its bracketed placeholders and example bullets are flavor cues to replace with real content. Generic placeholder text is worse than a short accurate description.
4. If an instruction file already exists, read it end-to-end before editing:
   - `AGENTS.md` exists: that is the file to update.
   - Only `CLAUDE.md` exists: treat its content as the existing file. The end state is the content living in `AGENTS.md` with `CLAUDE.md` symlinked to it — move it with `git mv CLAUDE.md AGENTS.md` (plain `mv` if untracked), then `ln -s AGENTS.md CLAUDE.md`, and tell the user you converted it.
   - Both exist with different content: stop and ask the user which file wins before editing anything.
5. **Score the existing file** (if one exists) against [`references/quality-criteria.md`](references/quality-criteria.md). The score sets the edit posture — follow the bands in the rubric's Assessment Process exactly: high scores are left alone, mid scores get surgical updates to the weakest sections within the file's existing structure, and restructuring to the template only happens at the lowest band with the user's confirmation first.
6. **Adapt the template to the repo** before writing. The bar for every line: it is non-obvious, an agent would not cheaply discover it by searching, and it is specific enough that it cannot be misused as a shortcut to skip thinking. Cut anything that fails this — a thin, high-signal file beats a complete one.
   - **Header**: replace `# <project name>` and the one-line description with what this repo actually is and who it serves.
   - **Project Rules**: write 3-6 concrete, enforceable rules an agent keeps getting wrong here — not generic posture. Drop the placeholder examples; if nothing project-specific applies, keep the section short rather than padding it.
   - **Verification**: name concrete checks and commands for this repo, preferring ones proven by CI or manifest scripts.
   - **In-Code Documentation**: only project-specific conventions (style deviations, what must be documented) and the repo's real invariants worth a `why` comment. Do not restate the language's default doc format or generic commenting advice — drop the section entirely if the repo has nothing worth stating.
   - **Key Decisions**: name the real architectural facts — central types, modules, entry points, runtime model — using actual identifiers from the survey. Each line earns its place. If the repo is too small to have meaningful decisions, keep it to a line or two rather than inventing content.
7. When updating, preserve user-written guidance and unrelated instructions; land changes in the sections they belong to, per the score band from step 5. Never silently discard existing content — if the existing file conflicts with the template and the right merge is not obvious, surface the conflict instead of guessing.
8. Keep the result tight: one file, no extra explanatory docs. A healthy `AGENTS.md` is usually 40–100 lines; past ~150, look for cuts.
9. **Re-score the final file** against the rubric before declaring the task done. Fix anything fixable without speculation. Done means ≥ 70, or an honestly sparse lower score for a genuinely small repo — do not pad with generic advice to clear the floor.
10. If the repo already used `CLAUDE.md`, or the user asks for it, ensure `CLAUDE.md` is a symlink to `AGENTS.md` so every agent reads the same file. Do not create this link unprompted in a repo that never had a `CLAUDE.md`.

## What To Verify

- `AGENTS.md` exists at the intended path and leads with the project name and a one-line description.
- All major sections are present: Project Rules, Verification, Key Decisions — plus In-Code Documentation when the repo has conventions or invariants worth stating.
- Every command in Verification matches CI, a Makefile/justfile, or a manifest script — or was otherwise confirmed to work.
- Every identifier named in Key Decisions resolves against the actual repo.
- The final rubric pass from step 9 is done and its threshold met.
- No unrelated `AGENTS.md` content was removed unless the user asked for replacement.
- If a `CLAUDE.md` was converted or requested, it is a symlink that resolves to `AGENTS.md`.

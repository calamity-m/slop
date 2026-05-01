# AGENTS.md Quality Criteria

Use this rubric when **updating** an existing `AGENTS.md` (or `CLAUDE.md`) to decide what is worth preserving, what to rewrite, and what to add. When **creating** from scratch, use it as a final pass before declaring the file done.

Score each criterion out of its weight. Total is out of 100. Anything under 70 means the file should be improved before declaring the task done; under 50 means a near-rewrite is justified.

## Scoring Rubric

### 1. Repository Map (20 points)

Maps to template section 7.

- **20**: Key directories explained with purpose, entry point(s) named with launch command, data flow described in a few lines or a short arrow chain. An agent reading only this section can locate the right file for a typical change.
- **15**: Map present, minor gaps (entry point missing a command, data flow vague).
- **10**: Bare directory listing with no purpose annotations, or entry points without context.
- **5**: One sentence, mostly hand-waving.
- **0**: No map at all.

Bonus considerations: paths must actually exist; commands must actually run.

### 2. Posture Coverage (15 points)

Maps to template sections 1–4 (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution).

- **15**: All four sections present, each with concrete rules an agent can apply (e.g. "state assumptions before editing", "every changed line traces to the request").
- **10**: All four present but one or two are generic / could apply to any repo.
- **5**: One or two sections missing, or all reduced to platitudes.
- **0**: No posture guidance.

### 3. Tooling Specificity (15 points)

Maps to template sections 5–6 (In-Code Documentation, Pre-commit Hooks).

- **15**: Doc format named for the actual language(s) (rustdoc, JSDoc, docstrings — not all of them). Pre-commit / lint / format / test commands named and runnable. No generic placeholders.
- **10**: Right tools named but commands missing or wrong flags.
- **5**: Generic ("use a linter") or wrong-language guidance left in.
- **0**: No tooling guidance.

### 4. Project-Specific Notes (10 points)

Maps to template section 8.

- **10**: Real observations — domain rules, design decisions, non-obvious conventions. Each line earns its place.
- **7**: A few real notes mixed with generic advice.
- **3**: Mostly "always run tests", "use conventional commits", or restates the language/framework already obvious from the repo.
- **0**: Empty, or nothing but filler.

Cap at 10 lines per the template. Long lists here are a smell.

### 5. Conciseness (10 points)

- **10**: Dense. Every line earns its place. No restating what code or filenames already say.
- **7**: Mostly tight, occasional padding.
- **3**: Verbose. Multiple paragraphs where a list would do.
- **0**: Mostly filler.

### 6. Currency (10 points)

- **10**: All commands work. All file paths exist. Tech stack matches `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod`.
- **7**: One or two stale references.
- **3**: Several broken paths or wrong commands.
- **0**: Severely outdated; commands fail; paths gone.

### 7. Actionability (10 points)

- **10**: Commands copy-paste cleanly. Steps are concrete. Paths are real.
- **7**: Mostly actionable, a few vague ones.
- **3**: Several "you should consider" or "ideally" hedges that an agent cannot act on.
- **0**: Theoretical advice with no executable instruction.

### 8. Surgical Update Hygiene (10 points)

Only scored when **updating** an existing file. Skip when creating from scratch (redistribute weight evenly across other criteria).

- **10**: User-written content outside the template's sections is preserved. Updates land in the right sections without rewriting unrelated prose. No silent deletions.
- **5**: Some unrelated content rewritten or moved without need.
- **0**: Existing guidance discarded or scrambled.

## Assessment Process

1. Read the existing `AGENTS.md` / `CLAUDE.md` end-to-end before scoring.
2. Cross-reference against the actual repo:
   - Try at least one documented command.
   - Open at least two referenced paths.
   - Check the language and framework against lock / manifest files.
3. Score each criterion. Note specific issues.
4. Decide:
   - **Score ≥ 85**: leave as-is or apply only the minor fixes the user asked for.
   - **70–84**: targeted updates to the lowest-scoring sections.
   - **50–69**: substantial rewrite of weak sections; preserve anything strong.
   - **< 50**: propose a near-rewrite to the user before doing it; do not silently overwrite.
5. List concrete improvements before editing. Apply them surgically.

## Red Flags

- Commands that would fail (wrong paths, missing deps, removed scripts).
- References to deleted files or folders.
- Doc-format guidance for languages the repo does not use.
- Pre-commit hook section naming tools the repo does not have configured.
- "TODO" markers left from a previous pass.
- Generic advice copy-pasted from a template with no repo-specific tailoring.
- Project-Specific Notes section listing the same facts a glance at `package.json` would reveal.
- Repository Map listing every directory in the tree instead of the navigation-relevant ones.
- Conflicting guidance across multiple instruction files (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, etc.) — flag for the user, do not silently reconcile.

# AGENTS.md Quality Criteria

Use this rubric when **updating** an existing `AGENTS.md` (or `CLAUDE.md`) to decide what is worth preserving, what to rewrite, and what to add. When **creating** from scratch, use it as a final pass before declaring the file done.

Score each criterion out of its weight. Total is out of 100. Anything under 70 means the file should be improved before declaring the task done; under 50 means a near-rewrite is justified.

## Scoring Rubric

### 1. Key Decisions (20 points)

Maps to template section 4.

- **20**: Real architectural facts — central types, modules, entry points, runtime model — named with actual identifiers. An agent reading only this section can orient and predict where a change ripples.
- **15**: Decisions present, minor gaps (a key module unnamed, runtime model vague).
- **10**: Mostly generic ("the app is well structured") with few real identifiers.
- **5**: One sentence, mostly hand-waving.
- **0**: No key decisions at all.

Bonus considerations: every named identifier must actually exist in the repo.

### 2. Verification Coverage (15 points)

Maps to template section 2 (Verification).

- **15**: Concrete repo-specific checks are present, with copy-pasteable commands or exact tool/module validation steps and guidance for when to use them.
- **10**: Verification guidance is present but partly generic or missing some common task paths.
- **5**: Verification is reduced to platitudes like "run tests" without commands or context.
- **0**: No verification guidance.

### 3. In-Code Documentation (15 points)

Maps to template section 3.

- **15**: Doc format named for the actual language(s) (rustdoc, JSDoc, docstrings — not all of them), and the repo's real `why`-worthy invariants named (event ordering, async cancellation, store/search, etc.). No generic placeholders.
- **10**: Right format named but invariants vague or generic.
- **5**: Generic ("document your code") or wrong-language guidance left in.
- **0**: No documentation guidance.

### 4. Project Rules Specificity (10 points)

Maps to template section 1.

- **10**: 3-6 concrete, enforceable rules an agent keeps getting wrong here. Each is project-specific and actionable.
- **7**: A few real rules mixed with generic posture.
- **3**: Mostly "always run tests", "use conventional commits", or restates obvious posture already covered elsewhere.
- **0**: Empty, or nothing but filler.

Long lists here are a smell — keep it to the rules that matter.

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
- "TODO" markers left from a previous pass.
- Generic advice copy-pasted from a template with no repo-specific tailoring.
- The template's `<bracketed>` placeholders left in verbatim instead of replaced with real content.
- Lines an agent would discover on its own in seconds (the language, the framework, the directory names) — they dilute the signal.
- Vague posture loose enough to be cited as a shortcut ("make minimal changes") where a thinking task was warranted.
- Project Rules section restating generic posture instead of the rules this repo keeps getting wrong.
- Key Decisions naming types or modules that do not exist in the repo.
- Conflicting guidance across multiple instruction files (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, etc.) — flag for the user, do not silently reconcile.

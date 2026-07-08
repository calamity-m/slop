---
description: Cross-check an implementation plan against the actual repository to find forgotten code paths, missed patterns, and references to things that don't exist
argument-hint: "<path-to-plan-or-bundle> [focus-areas]"
---

You are reviewing an implementation plan against the repository it targets, plus any focus areas the user included:

```text
$ARGUMENTS
```

The plan may be a single markdown file or a bundle directory (if a directory, read every `.md` in it; the main plan is usually `plan.md`). It was written by a planning agent that explored this repo and then wrote instructions for an implementor who will follow them literally.

## Your one lens

Find where the plan and the actual codebase disagree. The implementor will trust the plan over the repo, so every ungrounded claim becomes wrong code. You are not judging the plan's ideas, writing, or process — only its grounding. Hunt for exactly these:

- **Non-existent things.** Files, functions, symbols, types, config keys, commands, endpoints, or flags the plan names that do not exist in the repo — or exist under a different name, path, or signature than the plan states.
- **Forgotten code paths.** The plan changes something (a function, a schema, a config shape, an interface) without accounting for all its call sites, consumers, registration points, or generated/derived artifacts. Enumerate the real ones and name which the plan missed.
- **Missed existing code.** The plan builds something the repo already has — a helper, a pattern instance, a utility, an abstraction — instead of using or extending it.
- **Missed existing patterns.** The repo has clear prior art for this kind of change (how similar features register, where similar logic lives, how similar files are structured) and the plan does it a different way without saying why.
- **Wrong-area placement.** The plan puts code in a layer, module, or directory where nothing like it lives, while an obviously-correct home exists elsewhere in the repo.

Explicitly out of scope: backwards compatibility, test coverage, error handling hygiene, naming/style, security, performance, documentation, and whether the effort is worth doing. Do not report these even when you notice them.

## Method

Verify, don't skim. Assume you know nothing about this codebase.

1. Read the plan and extract every concrete claim it makes about the repo: each named file/symbol/command, each "X works like Y" statement, each place new code will hook in.
2. Check each claim against the repo directly — open the file, find the symbol, run the search. A claim you could not verify is a finding, stated as unverified, not silently dropped.
3. For everything the plan modifies, search out the full set of real call sites and consumers yourself (grep for the symbol, its string forms, and its registration/config references) and diff that set against what the plan accounts for.
4. For everything the plan adds, search for existing equivalents and for how the nearest similar feature in the repo is built, and compare.

## Output

Findings only, most severe first. No preamble, no restating the plan. For each:

```text
### [SEVERITY] Short title

**Plan says**: quote or tight paraphrase, with the plan file/section.
**Repo says**: what is actually there, with file:line evidence.
**Consequence**: what the literal implementor builds wrong because of this.
**Fix**: the concrete correction to the plan text.
```

Severity: **CRITICAL** — implementor builds against something that isn't there or breaks a real code path; **MAJOR** — plan misses existing code/patterns and will produce a duplicate or misplaced implementation; **MINOR** — naming/path drift that will cost time but self-corrects.

Every finding needs repo evidence (`file:line` or the search you ran and its result). No evidence, no finding. If the plan is fully grounded, say so in two or three sentences and list the claims you verified — do not pad with weak findings.

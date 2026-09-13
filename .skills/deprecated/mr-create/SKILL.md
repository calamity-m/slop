---
name: mr-create
description: Create a merge/pull request from the current branch. Use when the user asks to open, draft, prepare, or write a PR/MR.
---

# MR Create

Use this skill to create a review request that is easy to understand for a reviewer seeing the branch cold: a why-first title and description, plus high-signal inline comments on complex, major, or potentially contentious changed lines.

## Core Rules

- Treat the current branch, target branch, and diff as source material. Do not invent rationale.
- If the current branch is not `main` or `master`, assume the review should merge the current branch into the repository default branch, preferring `main`/`master` when present.
- If the current branch is `main` or `master`, ask the user which source and target branches to use before creating anything.
- Analyze the diff before drafting the title or body. If the diff shows what changed but not why, ask the user for the missing intent.
- Make the title follow conventional commit style while stating the reason or outcome, not an implementation inventory.
- Fill the description from local templates, recent review descriptions, linked issues, commit messages, and the diff, in that order.
- Keep the description reviewer-oriented: lead with why, cover what in bullets, call out risks, review focus, and verification.
- Treat inline comments as reviewer signposts, not defenses: use them to explain non-obvious intent, tradeoffs, and constraints at the exact changed lines where reviewers will need that context.
- Add inline comments for complex, major, or potentially contentious changes when a brief line-level note would prevent confusion or repeated review questions.
- Do not create a review request until the local working tree and branch state are understood.

## Workflow

1. Establish branch intent:
   - Read the current branch, default branch, remotes, and upstream tracking state.
   - If on `main` or `master`, stop and ask for source and target branches.
   - If on another branch, use the current branch as source and default branch as target unless the user specified otherwise.
   - Push the branch only if needed to create the review request, and only after checking `git status --short`.
2. Understand the change:
   - Diff source against target with commit summaries and full file changes.
   - Read relevant files when the diff alone is not enough.
   - Read linked issues, tickets, or specs from branch names, commit messages, and changed docs when discoverable.
   - Write down the inferred why, what, risk areas, verification evidence, and candidate inline-comment locations.
   - For each candidate inline comment, note the exact changed file/line, the reviewer question it answers, and the shortest useful comment body.
   - If the why is unclear or ambiguous, ask the user before drafting.
3. Gather description inputs:
   - Load the provider reference from `references/` for exact create, template, recent-review, and inline-comment commands.
   - Find review request templates in the repository and follow their headings.
   - Read the last two merged or recently created review request descriptions for local tone, structure, and required sections.
   - Use existing issue references and closing keywords only when evidence supports the linkage.
4. Draft the review request:
   - Title: conventional commit style, outcome-oriented, and concise.
   - Opening: one or two sentences explaining the reason for the change.
   - What changed: bullets grouped by reviewer-relevant behavior or subsystem.
   - Verification: commands run, manual checks, or "Not run" with a reason.
   - Risk/review focus: call out migrations, compatibility, security, behavior changes, follow-up work, intentionally narrow choices, and where inline comments will provide line-level context.
   - Preserve required template sections even when the answer is `N/A`.
5. Create the review request:
   - Prefer file-backed body input over shell-quoted multiline text.
   - Set source and target branches explicitly.
   - Use draft mode when the branch is incomplete, checks have not run, or the user asks for a draft.
   - Capture the created URL.
6. Add inline comments when useful:
   - Prefer a small set of high-signal comments on the lines most likely to make review harder without context.
   - Comment on specific changed lines that carry complex logic, major behavior shifts, compatibility constraints, security/performance tradeoffs, intentionally narrow scope, or contentious product/architecture choices.
   - Explain the intent, constraint, or tradeoff, not the obvious code.
   - Keep each comment brief enough to scan during review; usually one or two sentences.
   - Prefer one concise comment per concern, and skip comments already covered clearly by nearby code comments or the review description.
   - If the provider CLI cannot create reliable inline comments, use the provider API reference or report the exact comment text and location for manual posting.
7. Finish with status:
   - Review request URL.
   - Source and target branches.
   - Title used.
   - Any inline comments posted or skipped.
   - Verification included in the description.

## Title Guidance

Use conventional commit style:

```text
<type>(<scope>): <outcome>
```

Choose the narrowest accurate type such as `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, or `ci`. Include a scope when it clarifies the affected subsystem. Keep the description outcome-oriented because it is likely to become the squash-merge commit subject.

Prefer:

```text
fix(search): prevent stale results after source changes
feat(snippets): preserve cursor context when editing
ci(analyzer): reduce noise from optional failures
```

Avoid:

```text
chore: update search.rs and app.rs
refactor(ui): add selected_sequence_id plumbing
fix: fix tests
```

If only a what-title is possible from the diff, the why is not known enough. Ask the user.

## Description Shape

Adapt to the repository template, but keep this information available:

```markdown
## Why

<Reason this change exists.>

## What

- <Behavior, contract, or workflow change.>
- <Important implementation note only if reviewers need it.>

## Verification

- <Command or manual check.>

## Review focus

- <Risky line, tradeoff, migration note, or N/A.>
```

## Inline Comment Criteria

Use inline comments to make the review easier, not longer. Add one when at least one is true:

- The change is large or central enough that reviewers need an entry point into the reasoning.
- The code is correct but surprising without context.
- The approach intentionally avoids a larger refactor.
- A changed line carries a compatibility, migration, security, or performance tradeoff.
- A product, API, data-model, or architecture choice is likely to be contentious.
- Reviewers are likely to ask why a narrow or odd-looking choice was made.

Do not add inline comments that restate the diff, apologize for code, preemptively defend every decision, or turn the review into a guided tour of straightforward changes.

## References

- `references/github.md` - GitHub PR creation, templates, recent PRs, and line comments.
- `references/gitlab.md` - GitLab MR creation, templates, recent MRs, and line discussions.

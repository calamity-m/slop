---
name: mr-create
description: Create a GitHub pull request or GitLab merge request from the current branch. Use when the user asks to open, draft, prepare, or write a PR/MR with a why-first title and description, including templates, recent review examples, and inline context comments for risky code.
---

# MR Create

Use this skill to create a review request whose title and description explain why the change exists, with enough concrete detail for reviewers to understand what changed and where to focus.

## Core Rules

- Treat the current branch, target branch, and diff as source material. Do not invent rationale.
- If the current branch is not `main` or `master`, assume the review should merge the current branch into the repository default branch, preferring `main`/`master` when present.
- If the current branch is `main` or `master`, ask the user which source and target branches to use before creating anything.
- Analyze the diff before drafting the title or body. If the diff shows what changed but not why, ask the user for the missing intent.
- Make the title state the reason or outcome, not an implementation inventory.
- Fill the description from local templates, recent review descriptions, linked issues, commit messages, and the diff, in that order.
- Keep the description reviewer-oriented: lead with why, cover what in bullets, call out risks and verification.
- Add inline comments only for areas that are genuinely dubious, surprising, risky, or likely to attract reviewer attention.
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
   - Write down the inferred why, what, risk areas, and verification evidence.
   - If the why is unclear or ambiguous, ask the user before drafting.
3. Gather description inputs:
   - Load the provider reference from `references/` for exact create, template, recent-review, and inline-comment commands.
   - Find review request templates in the repository and follow their headings.
   - Read the last two merged or recently created review request descriptions for local tone, structure, and required sections.
   - Use existing issue references and closing keywords only when evidence supports the linkage.
4. Draft the review request:
   - Title: why-first, outcome-oriented, and concise.
   - Opening: one or two sentences explaining the reason for the change.
   - What changed: bullets grouped by reviewer-relevant behavior or subsystem.
   - Verification: commands run, manual checks, or "Not run" with a reason.
   - Risk/review focus: call out migrations, compatibility, security, behavior changes, follow-up work, or intentionally narrow choices.
   - Preserve required template sections even when the answer is `N/A`.
5. Create the review request:
   - Prefer file-backed body input over shell-quoted multiline text.
   - Set source and target branches explicitly.
   - Use draft mode when the branch is incomplete, checks have not run, or the user asks for a draft.
   - Capture the created URL.
6. Add inline comments when useful:
   - Only comment on specific changed lines that need reviewer context.
   - Explain the concern or tradeoff, not the obvious code.
   - Prefer one concise comment per concern.
   - If the provider CLI cannot create reliable inline comments, use the provider API reference or report the exact comment text and location for manual posting.
7. Finish with status:
   - Review request URL.
   - Source and target branches.
   - Title used.
   - Any inline comments posted or skipped.
   - Verification included in the description.

## Title Guidance

Prefer:

```text
Prevent stale search results after source changes
Make snippet editing preserve cursor context
Reduce CI noise from optional analyzer failures
```

Avoid:

```text
Update search.rs and app.rs
Add selected_sequence_id plumbing
Fix tests
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

Add an inline comment when at least one is true:

- The code is correct but surprising without context.
- The approach intentionally avoids a larger refactor.
- A changed line carries a compatibility, migration, security, or performance tradeoff.
- Reviewers are likely to ask why a narrow or odd-looking choice was made.

Do not add inline comments that restate the diff, apologize for code, or preemptively defend every decision.

## References

- `references/github.md` - GitHub PR creation, templates, recent PRs, and line comments.
- `references/gitlab.md` - GitLab MR creation, templates, recent MRs, and line discussions.

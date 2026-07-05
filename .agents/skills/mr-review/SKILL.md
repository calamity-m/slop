---
name: mr-review
description: Review an existing merge/pull request with a code-quality focus. Use when the user asks to review a PR/MR, inspect title and description, review linked issues or docs, analyze open discussions, compare changed code against existing patterns, record findings, or leave line-specific review comments.
---

# MR Review

Use this skill to review an existing PR/MR as a reviewer. The goal is to understand why the change exists, evaluate the changed branch against repository standards and existing code, and leave high-signal line comments.

## Core Rules

- Start by creating or updating a review record with `scripts/init_record.sh`; after compaction or resume, read the record before doing new work.
- Review context before code. Read title, description, linked issues, open threads, and repository guidance before opening the MR diff.
- Treat the branch as code under review, not just a patch. Inspect changed code in its final form and compare it with the existing base implementation.
- Use `/tmp/mr-review/` as the persistent working record. Keep assumptions, understanding, findings, and posted comments there.
- Prefer line-specific comments. Use a detached PR/MR comment only when the concern is about the review request itself, such as unclear rationale, missing description, or the change not being justified.
- Prioritize correctness, security, data loss, compatibility, maintainability, observability, test coverage, and consistency with local patterns.
- Use the `code-review` skill (`.agents/skills/code-review/SKILL.md`) as the standard for the code-quality pass, whether performed locally or by an authorized subagent.
- Do not post style-only, speculative, or nitpick comments unless they materially affect review quality.
- Use subagents only when the active request explicitly authorizes delegation. If delegation is not authorized, perform the same code-quality pass locally and record that choice.
- Never post a comment without user approval. Present every proposed comment to the user with its file, line, and exact text, wait for explicit approval, and post only the approved comments.

## Review Record

Run the record script from the skill directory before the workflow:

```bash
.agents/skills/mr-review/scripts/init_record.sh --review <id-or-url>
```

Seed known provider and branch fields when available:

```bash
.agents/skills/mr-review/scripts/init_record.sh \
  --provider <provider> \
  --review <id-or-url> \
  --base <base-branch> \
  --branch <review-branch>
```

Update the record after every phase:

- After reading title, description, linked data, and open threads.
- After reading repository architecture, patterns, and coding standards.
- After reading the MR diff.
- After reading existing base-branch code.
- After completing the code-quality pass.
- After proposing comments and receiving the user's approval decisions.
- After posting approved comments.

The record must always include the next intended step so a compacted or resumed session can continue without guessing.

## Workflow

1. Establish the target review:
   - Identify the PR/MR from the user request or current branch.
   - Load the matching provider reference from `references/` for exact metadata, thread, diff, and line-comment commands.
   - Create or update the review record and keep its path visible in status updates.
   - Inspect `git status --short` and preserve unrelated local changes.
2. Review title and description:
   - Read the title, description, source branch, target branch, author, labels, draft state, and current head SHA.
   - Record the claimed reason for the change, expected behavior, verification claims, and missing rationale.
3. Review linked data:
   - Read linked issues, tickets, docs, designs, incidents, release notes, or external links referenced by the description, commits, or branch name.
   - Record acceptance criteria, constraints, affected users, compatibility promises, and any contradiction with the MR description.
4. Review open threads and discussions:
   - Read unresolved or ongoing review threads before looking at the diff.
   - Record existing concerns, reviewer expectations, and areas already contested.
   - Do not let existing threads replace independent review; use them as context.
5. Review repository guidance before the MR diff:
   - Read architecture docs, coding standards, contribution docs, ADRs, nearby README files, test conventions, and framework-specific patterns that govern the changed area.
   - Record the standards that should shape the review.
6. Read the MR diff:
   - Read the full diff against the target branch, including file stats and commit summaries.
   - Identify changed subsystems, public contracts, migrations, configuration, tests, and generated files.
   - Record notable code changes and areas needing deeper inspection.
7. Read existing base code:
   - Inspect the same files or neighboring implementations from the target branch without the MR changes.
   - Compare the MR branch behavior against the pre-existing architecture and local patterns.
   - Record mismatches, precedent, and whether the MR is consistent with the codebase.
8. Run a code-quality pass on the MR branch:
   - Focus on the actual code that exists in the review branch, not only the diff.
   - Read and apply `.agents/skills/code-review/SKILL.md` before forming findings.
   - If delegation is authorized, spawn a subagent to run `/code-review` on the changed area and ask for findings grounded in current branch files.
   - If delegation is not authorized, perform that pass locally using the same `code-review` criteria.
   - Compile findings into the review record, separating confirmed issues from observations and questions.
9. Propose comments and get approval:
   - Convert only confirmed, actionable findings into review comments.
   - Attach each code finding to the most specific changed line that supports it.
   - Use a detached PR/MR comment only for review-request-level concerns such as an absent rationale, misleading description, or insufficient reason for the MR to exist.
   - Show the user every proposed comment with file, line, and exact text, plus any findings deliberately not proposed.
   - Wait for explicit approval; drop or revise comments the user rejects, and record each decision.
10. Post approved comments and finish:

- Post only user-approved comments as concise line comments with evidence, impact, and the smallest useful ask.
- Avoid broad summaries unless the provider requires a review submission body.
- Update the record with every posted comment, skipped finding, and remaining uncertainty.
- Finish with review URL, record path, comments posted, and any findings deliberately not posted.

## Review Record Shape

Keep the record concise but complete enough to resume:

```markdown
# MR Review State

Target:

- Provider:
- Review:
- Repository:
- Branch:
- Base:
- Head SHA:

Context:

- Title/description understanding:
- Linked data:
- Open threads:
- Pre-diff repo guidance:

Code understanding:

- MR changes:
- Existing base behavior:
- Affected areas:
- Tests and verification:

Review pass:

- General observations:
- Code-quality findings:
- Subagent findings:
- Questions:

Comments:

- Proposed:
- Approved/rejected by user:
- Posted:
- Skipped with reason:

## Next step:
```

## Subagent Task Shape

Use this prompt only when delegation is explicitly authorized in the active conversation:

```text
Run /code-review on the current PR/MR branch area, following `.agents/skills/code-review/SKILL.md`, not just the diff. Inputs: changed file list, current branch files, relevant base-branch examples, repository coding standards, and review context. Focus on correctness, security, maintainability, local pattern consistency, and test coverage. Output confirmed findings with file/line references, severity, impact, and suggested reviewer comment text. Do not edit files or post comments.
```

## Comment Standards

- Lead with the issue and impact, not with praise or narration.
- Ask for a concrete change when a fix is clear.
- Use questions only when the code is genuinely ambiguous.
- Cite local evidence when disagreeing with an existing thread or when a pattern conflict is subtle.
- Do not post duplicate comments for the same root cause.
- Do not post comments on unchanged lines unless the provider requires that position for the changed hunk and the finding is caused by the MR.

## References

- `references/github.md` - GitHub PR metadata, linked issues, review threads, diff reading, base-code inspection, and line comments.
- `references/gitlab.md` - GitLab MR metadata, linked issues, discussions, diff reading, base-code inspection, and line discussions.

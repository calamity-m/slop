---
name: mr-address
description: Address feedback, failed checks, review threads, and follow-up commits on an existing merge/pull request. Use when the user asks to fix or address PR/MR comments or failures.
---

# MR Address

Use this skill to work an existing review until failed checks and review feedback are handled with focused commits and clear replies.

## Core Rules

- Start by creating or updating a checkpoint with `scripts/init_checkpoint.sh`; after compaction or resume, read the checkpoint before doing new work.
- Treat provider state, git state, and the checkpoint as the source of truth. Do not rely on memory for what was fixed, pushed, or replied to.
- Understand before editing. Read the diff, description, linked context, current branch state, checks, and comments before making changes.
- Keep fixes small and reviewable. Every changed line should map to a failed check, review thread, or directly related regression.
- Treat checks as the gate. After any pushed change, update the checkpoint and return to check status before broad comment replies.
- Do not reply to or resolve a thread until you know whether it was fixed, rejected with rationale, or only informational.
- If a review comment conflicts with codebase evidence, tests, or another comment, state the disagreement plainly and cite the evidence.
- Use subagents only when the active request explicitly authorizes delegation. Otherwise, perform the same analysis locally.

## Checkpoint

Run the checkpoint script from the skill directory before the workflow loop:

```bash
.agents/skills/mr-address/scripts/init_checkpoint.sh --review <id-or-url>
```

The script creates a Markdown state file under `/tmp/mr-address/` and prints the path. Pass any known fields to seed the note:

```bash
.agents/skills/mr-address/scripts/init_checkpoint.sh \
  --provider <provider> \
  --review <id-or-url> \
  --base <base-branch> \
  --branch <review-branch>
```

Update the checkpoint after every phase:

- After reading the diff and description.
- After each check/pipeline pass.
- After each commit and push.
- After reviewing comment groups.
- Before and after replying to threads.

The checkpoint must always include the next intended step so a compacted or resumed session can continue without guessing.

## Workflow Loop

1. Establish the target review:
   - Identify the PR/MR from the user request or current branch.
   - Load the matching provider reference from `references/` for exact check, log, thread, reply, and resolution commands.
   - Create or update the checkpoint and keep its path visible in status updates.
   - Confirm the local branch is the review branch.
   - Inspect `git status --short` and preserve unrelated local changes.
2. Read the change:
   - Read the full diff against the target branch.
   - Read the title and description.
   - Read linked tickets, issues, specs, or docs when referenced by the description or comments.
   - Note the intended behavior, risky files, and test surface in the checkpoint.
3. Review checks and pipeline status:
   - List failed, pending, skipped, and passing jobs.
   - For each failed job, collect the relevant log excerpt.
   - Correlate each failure with the diff before editing.
   - If delegation is authorized, spawn one analysis subagent per failed job.
   - Apply fixes that are backed by logs and code evidence.
   - Commit and push any check-related fixes.
   - Update the checkpoint with statuses, fixes, commits, and the next step.
   - If changes were pushed, re-check status and repeat this step until no actionable failures remain.
4. Review threads and comments:
   - Read unresolved review threads first, then other comments.
   - Group comments by file, line, and underlying concern.
   - Identify comments already addressed by existing commits.
   - If delegation is authorized, spawn bounded analysis subagents for independent threads or thread groups.
   - Apply accepted fixes locally.
   - Commit and push coherent batches.
   - Update the checkpoint with comment decisions, fixes, commits, and the next step.
   - If code changed, return to check status before replying.
5. Reply to threads and comments:
   - Reply to fixed threads with the commit SHA or concise change summary.
   - Reply to disagreed threads with evidence and rationale.
   - Reply to informational threads only when a response is useful.
   - Resolve threads only when the concern is actually addressed and the provider supports resolution.
   - Update the checkpoint with reply and resolution state.
6. Finish with status:
   - Commits created and pushed.
   - Current check status.
   - Threads fixed, disagreed with, replied to, resolved, or left open.
   - Remaining blockers or decisions needed from a human.
   - Checkpoint path.

## Loop Bounds

- Do not run an unbounded repair loop silently.
- After each pushed batch, checkpoint and re-read current provider state.
- If checks fail for a new unrelated reason, record the evidence and ask before expanding scope.
- If a second repair pass does not converge, stop with the checkpoint updated and summarize the blocker.

## Commit And Push Policy

- Stage only files changed for the current fix.
- Prefer one commit per coherent cause: one failed job, one review concern, or a tightly related group.
- Use the repository's commit-message convention when obvious.
- Push after each coherent batch so checks can rerun.
- After pushing, re-check status before posting final replies.

## Subagent Task Shapes

Use these prompts only when delegation is explicitly authorized in the active conversation.

Failed job analysis:

```text
Analyze this failed PR/MR job. Inputs: relevant diff, job name, failing log excerpt, and repo test conventions. Output: root cause, whether this PR/MR likely caused it, smallest recommended fix, and files likely involved. Do not edit.
```

Review thread analysis:

```text
Analyze this unresolved PR/MR thread. Inputs: comment text, surrounding diff, relevant local files, and repo conventions. Output: whether a code change is required, whether you agree with the reviewer, smallest recommended fix, and files likely involved. Do not edit.
```

Use worker subagents for code edits only when write scopes are disjoint and explicit. Tell each worker it is not alone in the codebase and must not revert unrelated edits.

## References

- `references/github.md` - GitHub review checks, failed job logs, comments, review threads, replies, and resolution.
- `references/gitlab.md` - GitLab review pipelines, failed job logs, discussions, notes, replies, and resolution.

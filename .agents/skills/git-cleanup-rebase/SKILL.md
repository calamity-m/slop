---
name: git-cleanup-rebase
description: Help a user cleanup a git branch through rebase and squashing.
disable-model-invocation: true
---

# Git Cleanup Rebase

Clean up a feature branch into review-sized commits without hand-editing the rebase todo list.
Generate a deterministic plan, validate it, execute it, then show the rewrite before anyone pushes.

Always resolve scripts relative to this skill directory, not relative to the repository being cleaned up.

## Workflow

1. Resolve the base branch explicitly and inspect the full feature range with `git log --reverse --oneline <base>..HEAD`.
2. Decide the cleanup shape before touching history:
   - Prefer one final commit when the branch is one logical change or the intermediate commits are mostly noise.
   - Split into multiple chunks only when a reviewer benefits from reading them separately.
   - Keep fixup, typo, and checkpoint commits inside the nearest adjacent feature chunk.
   - Only group adjacent commits in their current order. Do not reorder commits or split commits.
   - If the branch needs reordering, commit splitting, or contains merge commits in the feature range, stop and tell the user this skill is not the right tool.
3. Check safety before execution:
   - Require a clean worktree, including no staged, unstaged, or untracked files.
   - Stop on detached `HEAD`, in-progress rebase or merge operations, merge commits in the range, or a diverged upstream branch.
   - If the current branch already has an upstream, explain that rewriting history will require a later `--force-with-lease`, then wait for explicit user confirmation before using `--allow-published`.
   - Existing stashes are left untouched.
4. Write a JSON plan that matches [references/plan-format.md](./references/plan-format.md). Put the plan outside the repository, for example `/tmp/cleanup-plan.json`, so validation still sees a clean worktree.
5. Validate the plan and repo state:

```bash
<skill-dir>/scripts/validate-plan.py --plan /tmp/cleanup-plan.json
```

Add `--allow-published` only after the user confirms rewriting a branch that already has an upstream.

6. Execute the plan. The runner creates a backup branch and applies the rewrite with `GIT_SEQUENCE_EDITOR` plus a scripted `GIT_EDITOR`:

```bash
<skill-dir>/scripts/run-plan.py --plan /tmp/cleanup-plan.json
```

7. Show the rewrite with the backup branch that `run-plan.py` prints:

```bash
<skill-dir>/scripts/show-results.py --base <base> --backup-branch <backup-branch>
```

8. Summarize the before and after history, note whether the tree changed, and ask the user what to do next. Never push automatically.

## Plan Rules

- The plan must cover every commit in `base..HEAD` exactly once and in the exact current order.
- Each chunk becomes one final commit.
- Every chunk needs a non-empty `subject`.
- `body` is optional and should stay short and review-focused.
- One final commit is valid. Use it whenever splitting the branch would not materially help reviewers.

## Failure Handling

- If validation fails, fix the plan or stop.
- If execution fails and a rebase is in progress, tell the user the exact choices:
  - `git rebase --abort` to return to the pre-run state.
  - Continue manually only if they intentionally want to debug the rewrite.
- Treat the backup branch as the recovery point. Always report its name.
- If `show-results.py` reports a tree change, treat that as suspicious and do not recommend pushing until the user reviews it.

## Resources

### scripts/

- `scripts/validate-plan.py`: validate plan shape, commit coverage, and preflight git safety checks.
- `scripts/run-plan.py`: create a backup branch and run the scripted interactive rebase.
- `scripts/show-results.py`: show before and after logs, `git range-diff`, and tree equality.

### references/

- `references/plan-format.md`: JSON plan schema, chunking rules, and examples.

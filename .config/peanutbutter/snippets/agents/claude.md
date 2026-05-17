---
tags:
  - ai
  - claude
  - git
---

# Claude Code

## commit - headless /commit skill

```bash
claude -p --dangerously-skip-permissions "/commit"
```

## complete small github issue end-to-end

```bash
claude "$(cat <<'PROMPT'
Pick a small, self-contained open GitHub issue from this repo and complete it end to end:

1. **Select** - run `gh issue list`, choose the smallest in-scope issue (prefer lower tier/priority labels). State which issue you picked and why.

2. **Branch** - `git checkout -b <type>/<short-slug>` matching the issue.

3. **Implement** - make the minimal change that satisfies every acceptance criterion in the issue. No scope creep.

4. **Check** - before committing, go through the issue's acceptance criteria line by line. Close any gaps now (e.g. docs listed as required, config examples, README mentions). Do not proceed until every criterion is met.

5. **Commit** - use /commit to stage and write a conventional commit. Include `Closes #<n>` in the body.

6. **Push** - push the branch.

7. **PR** - use /mr-create to open a pull request.
PROMPT
)"
```

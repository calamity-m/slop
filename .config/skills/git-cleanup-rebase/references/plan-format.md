# Plan Format

Write the cleanup plan as JSON.
Store the file outside the repository worktree, for example `/tmp/cleanup-plan.json`.

Use `git log --reverse --format='%H %s' <base>..HEAD` before drafting it.

## Schema

```json
{
  "base": "origin/main",
  "chunks": [
    {
      "subject": "feat(auth): add token refresh flow",
      "body": "Keep auth behavior separate from later UI cleanup.",
      "commits": [
        "1111111111111111111111111111111111111111",
        "2222222222222222222222222222222222222222"
      ]
    },
    {
      "subject": "refactor(ui): simplify empty state rendering",
      "commits": ["3333333333333333333333333333333333333333"]
    }
  ]
}
```

## Rules

- Set `base` to the exact branch or commit the feature branch should be reviewed against.
- Cover every commit in `base..HEAD` exactly once.
- Keep commits in their current oldest-to-newest order.
- Only group adjacent commits into a chunk.
- Do not reorder commits.
- Do not split a commit.
- Use one chunk when the branch is one logical change.
- Use multiple chunks only when the review becomes materially clearer.
- Keep `subject` short and specific.
- Keep `body` optional, short, and focused on reviewer context.

## One-Commit Example

```json
{
  "base": "origin/main",
  "chunks": [
    {
      "subject": "feat(search): add saved search filters",
      "body": "Collapse WIP and fixup commits into one reviewable change.",
      "commits": [
        "1111111111111111111111111111111111111111",
        "2222222222222222222222222222222222222222",
        "3333333333333333333333333333333333333333"
      ]
    }
  ]
}
```

## Multi-Chunk Example

```json
{
  "base": "origin/main",
  "chunks": [
    {
      "subject": "feat(api): add widgets endpoint",
      "commits": [
        "1111111111111111111111111111111111111111",
        "2222222222222222222222222222222222222222"
      ]
    },
    {
      "subject": "feat(ui): add widgets page",
      "body": "Keep the UI review separate from the API shape.",
      "commits": [
        "3333333333333333333333333333333333333333",
        "4444444444444444444444444444444444444444"
      ]
    }
  ]
}
```

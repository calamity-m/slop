# Publishing a breakdown to GitHub

Uses the `gh` CLI. Each ticket file becomes one issue; a tracking issue is
always created as the parent, since GitHub has no native epic. Creating
issues is outward-facing — confirm the target repo, the ticket list, and any
labels with the user before the first `gh issue create`.

## Preflight

```bash
gh auth status
gh repo view --json nameWithOwner   # confirm this is the intended repo; use -R owner/repo otherwise
```

Skip any ticket whose index entry already records an issue URL — re-publishing
must not create duplicates.

## Create the child issues

For each ticket file, the H1 is the title and the rest is the body:

```bash
title="$(head -1 T1-example.md | sed 's/^# *//')"
tail -n +2 T1-example.md | gh issue create --title "$title" --body-file - [--label "..."]
```

`gh issue create` prints the issue URL — capture it per ticket.

## Create the tracking issue

Create it after the children so it can reference their numbers. Body: the
index's Sequencing section plus a task list, which GitHub renders with live
progress:

```markdown
- [ ] #101 T1 — <title>
- [ ] #102 T2 — <title> (depends on T1)
```

Include a link to the spec file (repo path or blob URL).

## Backfill

Write the URLs back into the breakdown markdown — the tracking issue URL into
the index's "Published to" line, each child URL into its index entry. Then
show the user the tracking issue URL.

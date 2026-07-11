# Publishing a breakdown to GitLab

Uses the `glab` CLI. Each ticket file becomes one issue; a tracking issue is
always created as the parent (epics exist only on Premium group plans — offer
one only if the user asks and the group supports it). Creating issues is
outward-facing — confirm the target project, the ticket list, and any labels
with the user before the first `glab issue create`.

## Preflight

```bash
glab auth status
glab repo view   # confirm this is the intended project; use -R group/project otherwise
```

Skip any ticket whose index entry already records an issue URL — re-publishing
must not create duplicates.

## Create the child issues

For each ticket file, the H1 is the title and the rest is the body:

```bash
title="$(head -1 T1-example.md | sed 's/^# *//')"
glab issue create --title "$title" --description "$(tail -n +2 T1-example.md)" [--label "..."]
```

`glab issue create` prints the issue URL — capture it per ticket.

## Create the tracking issue

Create it after the children so it can reference their numbers. Body: the
index's Sequencing section plus a task list, which GitLab renders with live
progress:

```markdown
- [ ] #101 T1 — <title>
- [ ] #102 T2 — <title> (depends on T1)
```

Include a link to the spec file. On tiers with issue links, `/blocks #101`
quick actions in child descriptions encode the dependency graph — optional,
and harmless if the instance ignores them.

## Backfill

Write the URLs back into the breakdown markdown — the tracking issue URL into
the index's "Published to" line, each child URL into its index entry. Then
show the user the tracking issue URL.

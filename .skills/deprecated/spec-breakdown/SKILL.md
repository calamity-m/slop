---
name: spec-breakdown
description: Break an engineering spec/PRD document into a sequenced set of implementation tickets — one markdown file per ticket plus an index — and optionally publish them as issues to GitHub, GitLab, or Jira. Use whenever the user wants to turn a spec, PRD, or requirements doc into tickets, issues, stories, or a work breakdown, or asks to publish a breakdown to a tracker. Not for writing the spec itself or for implementing the tickets.
disable-model-invocation: true
---

# Spec breakdown

Turns a spec document into the set of tickets whose completion completes the
spec. The breakdown is **always markdown first**: a directory of standalone
ticket files plus an index, committed beside the spec. Publishing to a
tracker is an optional second step that derives every issue mechanically
from those files — never a different generation path. That split is the
point: the markdown is reviewable and diffable before anything outward-facing
happens, it drives implementation directly when no tracker is involved, and
it stays the source of truth (with issue URLs backfilled) after publishing.

This skill produces tickets; it does not write or revise the spec, and it
does not implement anything. When the spec itself needs work, or the user
wants the tickets executed, surface that and let them choose the next step.

## The breakdown files

For a spec at `docs/specs/<spec-slug>/spec.md`, the breakdown lives
alongside it in the same directory:

```
docs/specs/<spec-slug>/
├── spec.md                 # the spec this breakdown derives from
├── tickets.md              # index: sequencing, checklist, issue URLs
├── T1-<ticket-slug>.md     # one ticket = one file = one issue
└── T2-<ticket-slug>.md
```

Each ticket file's H1 is the issue title and everything below it is the
issue body — a ticket must read as a complete work item on its own
(`cat T1-*.md` should look like a good issue). Create files with the
bundled scripts — never hand-roll them:

```bash
scripts/init-breakdown.sh <spec-slug> --title "Human Title"   # directory + index
scripts/new-ticket.sh <spec-slug> <n> <ticket-slug> --title "Human Title"
```

(Paths relative to this skill directory; slugs kebab-case.) Both scripts
resolve from the git root, seed from `templates/`, and never overwrite.
`new-ticket.sh` does not touch the index — add each ticket's entry there
yourself.

## Breakdown workflow

### 1. Read the spec

Locate it (user-named, else `ls docs/specs/*/spec.md`; ask if several match) and
read it fully. Two checks before deriving anything:

- **Open questions**: an unresolved question becomes a blocked or wrong
  ticket. If the spec's Open questions section is non-empty, list them to
  the user and ask whether to resolve first or break down around them.
- **Requirements exist**: a doc without numbered, testable requirements
  can't be covered by tickets. If that's what you're holding, say so — this
  skill starts from a finished spec, not a brief.

### 2. Derive the tickets

The standard:

- **Coverage**: every functional requirement maps to at least one ticket,
  and every ticket names the requirement numbers it implements. Sweep for
  orphans in both directions before writing files. Non-functional
  requirements map to tickets where they need dedicated work, and into the
  acceptance checks of the tickets they constrain otherwise.
- **Sizing**: vertical slices, each roughly one reviewable MR/PR of work —
  but tickets are self-contained units of change, not gates. Each ends with
  its own verifiable acceptance checks, never with "wait for review", so
  the whole set can be executed end-to-end in one continuous run (by an
  agent or a person) or picked off one MR at a time.
- **Dependencies**: minimal and real. A dependency exists when a ticket
  needs something another one builds — not to encode a preferred order;
  ordering preferences live in the index's Sequencing prose.

### 3. Write the files

`init-breakdown.sh`, then one `new-ticket.sh` per ticket, then fill
everything in. Numbers are stable: mark dropped tickets "(dropped)" in the
index rather than renumbering. Point tickets at spec sections instead of
restating the design, but include enough Context that a fresh implementor
isn't forced back into the whole spec for a one-line constraint. Sweep every
`<...>` placeholder from every file — replaced with real content, or deleted
if it was only instructional.

### 4. Present

Show the user the ticket list (number, title, implements, depends-on) and
the sequencing rationale, and point at the directory. Iterate on their
feedback in the files. Then offer publishing — and stop there if markdown is
all they want; the breakdown is complete without a tracker.

## Publishing

Only on the user's say-so, and only after the breakdown files are settled.
Read the reference for the chosen target — it carries the mechanics
(preflight, parent creation, per-ticket creation, backfill):

- GitHub → `references/github.md`
- GitLab → `references/gitlab.md`
- Jira → `references/jira.md`

Invariants regardless of target: confirm the destination (repo / project /
labels) with the user before creating anything, since issues are
outward-facing and messy to unwind; always create a parent (tracking issue
or epic) so the spec has one link; each child issue's title and body come
verbatim from its ticket file; skip tickets that already record an issue URL
so re-publishing never duplicates; and backfill every created URL into the
index when done.

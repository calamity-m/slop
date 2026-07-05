---
name: plan-t3
description: Planning for complex features, long-term efforts and cross-cutting concerns. Use when the user mentions "t3 plan" or "plan t3".
---

# Plan T3

A deliberate, expensive planning pipeline for sizeable work: long-term
efforts, complex features, large refactors, cross-cutting changes. It trades
tokens and time for a plan good enough that a **fresh agent with zero
conversation context** can implement it.

Two facts drive every design choice here:

1. **The implementor is not you.** The user always starts a new session for
   implementation, and the implementor is best treated as a **mid-level
   engineer**: competent with code, reliable at executing a clear pathway,
   but not equipped to make the architectural judgment calls you are making
   now. You are the senior engineer defining that pathway. Anything that
   lives only in this conversation is lost, and any decision you leave open
   gets made by someone with less context and less judgment than you have
   at this moment — so write everything the implementor needs into the
   bundle, decisions included.
2. **Your context window is the scarce resource.** Planning burns context
   fast. Push exploration, review, and comparison work into sub-agents that
   return digests; keep the main thread for synthesis and user interaction.

## Modes

Pick the mode from what the user is asking:

- **Plan mode** — the user describes new work, or wants to revise an existing
  bundle's plan. Run the pipeline below (for revisions, rejoin at the stage
  that matches the change — a scope change re-enters at Grill; a wording fix
  is just an edit plus a `issues.md` log line).
- **Implement mode** — the user wants to execute, resume, or check progress
  on an existing bundle (typical opening of a fresh session). Skip to
  "Implement mode" at the bottom.

## The bundle

Plans live **outside the repo** at `~/.agents/plans/<repo>/t3/<slug>/`
so they can never be accidentally committed. That location is fixed —
never redirect it (no env overrides, no temp dirs); a plan in `/tmp` dies
with the session.
Four files, four distinct jobs — do not let content bleed between them:

| File              | Audience                   | Job                                                                                                            |
| ----------------- | -------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `overview.md`     | Team lead / user           | Vet and approve the solution in two minutes                                                                    |
| `plan.md`         | Fresh implementation agent | Full instruction: context, design, deliverables, acceptance. More is better. Frozen once implementation starts |
| `deliverables.md` | Implementation agent       | The only file that tracks progress                                                                             |
| `issues.md`       | Everyone                   | Risk register + dated append-only log                                                                          |

Create the bundle with the bundled script — never hand-roll the files:

```bash
scripts/init-plan.sh <slug> --title "Human Title"
```

(Run it with a path relative to this skill directory. Slug is kebab-case,
1-3 words, e.g. `oauth-refresh`, `producer-config`.) The script derives
`<repo>` from the git root, seeds all four files from `templates/`, never
overwrites, and prints the paths. To find existing bundles:
`ls ~/.agents/plans/*/t3/` or `ls ~/.agents/plans/$(basename "$(git rev-parse --show-toplevel)")/t3/`.

Whenever a stage below (or implement mode) says to log something in
`issues.md`, use the bundled helper rather than editing the file — it keeps
the entry format and newest-at-top ordering from drifting across sessions:

```bash
scripts/log-issue.sh <bundle-dir> <author> <source> "<message>"
```

Sign as `agent:claude` (append a role in parens when useful, e.g.
`agent:claude (peer review)`). Set `<source>` to what raised the issue:
`self` for implementor self-review, `grugbrain`, `peer-review`, `user`, etc.
Entries are formatted as `- **YYYY-MM-DD — agent:claude - source:self** - ...`.
Edit `issues.md` directly only for the Risks register, which the helper
deliberately does not touch.

## Plan mode pipeline

Six stages, in order. Tell the user which stage you are entering as you go —
this is a long operation and they should see the shape of it. Run
`init-plan.sh` after the Grill stage, once the effort has a confirmed name
and scope.

### Stage 1 — Context Gathering

The most common planning failure is **searching too narrowly**: reading the
one obvious file and missing the second registration point, the config that
gates the feature, the test that encodes the real contract. Guard against it
structurally:

1. From the user's brief, list the _angles_ the work touches — not files,
   angles: entry points, adjacent subsystems, configuration, tests,
   conventions/prior art for similar changes, and (when relevant) git history
   of the affected area.
2. Spawn **parallel Explore sub-agents** (same turn), one per angle or
   sensible pairing, each with breadth "very thorough". Tell each agent it is
   feeding a planning operation: it should return file paths with one-line
   roles, established conventions, surprises, and open questions — a digest,
   not file dumps.
3. Synthesize the digests into a working context map. Then run the coverage
   check: _for each thing the brief promises, do I know where it lives, what
   touches it, and how similar changes were done before?_ Any "no" gets one
   more targeted sub-agent before you proceed.

Do not skip fan-out because the task "looks contained" — contained-looking
tasks are where the missed second registration point lives.

### Stage 2 — Grill

Invoke the `grill-me` skill. You've done the exploration, so the grill should
be pure judgment calls: scope boundaries, terminology, need-vs-want, the
assumptions your context map tempted you to make. Skip only when the brief is
already crisp — and say so with a one-line reason so the user can override.

After the grill, run `init-plan.sh` and record the shared-understanding
summary: Problem + Scope go into `overview.md`; confirmed facts and key terms
seed `plan.md`'s Context; deferred open questions become `issues.md` log
entries via `log-issue.sh` with the appropriate source, one per question.

### Stage 3 — Solution Exploration

Sketch **2-3 genuinely different approaches** (different in shape, not in
variable names). For each candidate, cover three things:

1. **The solution itself** — one paragraph: what changes, how it works,
   rough blast radius.
2. **Pros and cons** — honest ones, grounded in the Stage 1 context map,
   not generic ("more flexible") hand-waving. Name what each approach makes
   easy, what it makes hard, and what it forecloses.
3. **Development cost in context.** T3 efforts are large bodies of work, so
   judge complexity against the trajectory, not the snapshot: a more complex
   solution can be the right call now if it unblocks planned future areas or
   kills a pattern that's already repeating; equally, a first-cut or MVP
   does not need to be engineered to the highest standard, and gold-plating
   it delays the learning it exists to produce. State explicitly which
   situation this effort is in and let that anchor the comparison — the
   later peer review will challenge unjustified complexity, so complexity
   you keep should carry its justification from here.

If two options survive with genuinely unclear tradeoffs, offer the user the
`deliberate` skill; otherwise present the candidates with your recommendation
and get the user's pick before writing the plan. Record losing alternatives
and why they lost in `overview.md`.

### Stage 4 — Plan Writing

Write `plan.md` as the senior engineer handing a pathway to a mid-level
implementor: they will execute what you specify well, and improvise poorly
where you left gaps. The template's structure is the contract; the standard
to hit:

- **Context as settled fact.** Everything from Stage 1 the implementor needs,
  written declaratively. No "as discussed", no chat references — the
  implementor was not in the chat.
- **Design that shows the shape, not just the intent.** The Design section
  earns its keep when the implementor never has to re-derive what you
  already worked out. Include: **critical files** with the role each plays
  in the change; **the expected code path** — general control flow in
  pseudo-code, or "request enters here, flows through X, lands in Y" — for
  each significant behavior the plan adds or alters; and **architecture or
  infrastructure design** wherever the work touches it (component
  boundaries, data flow between systems, deployment/config/migration
  shape). A plan whose Design section is prose-only sends the implementor
  back into exploration you already paid for.
- **Deliverables are vertical slices** — independently demonstrable value,
  not horizontal layers. Each has concrete acceptance criteria: the command
  to run, the behavior to observe. Order them so value is proven early, not
  only at the end.
- **Decisions, not options.** The plan records what was chosen and why, never
  a menu. If you catch yourself writing alternatives, the decision belongs
  back in Stage 3.
- **Research marker sweep.** Scan the draft for "TBD", "need to investigate",
  "unclear whether", "figure out later" and similar hedges. For each: resolve
  it now by reading code (a sub-agent if it's more than a quick look), or —
  if it genuinely needs the user or an external party — log it via
  `log-issue.sh` and tell the user it blocks the affected deliverable. A hedge in `plan.md`
  is a guess delegated to someone with less context than you.

Then fill `deliverables.md` (status board + mirrored task checklists) and
draft `overview.md`.

### Stage 5 — Peer Review

Spawn **three reviewer sub-agents simultaneously**. Give each one only the
bundle contents plus the full text of its own reviewer file — no conversation
history, and no sight of the other reviewers' charters. The isolation is the
point: each reviewer simulates the fresh implementor and stays on its own
angle instead of converging with the others.

- [references/reviewer-risks.md](references/reviewer-risks.md) — Risks & Assumptions
- [references/reviewer-completeness.md](references/reviewer-completeness.md) — Completeness & Implementor Readiness
- [references/reviewer-grug.md](references/reviewer-grug.md) — Grug Simplicity

Merge findings: discard duplicates and nitpicks; apply unambiguous fixes
directly to the bundle; collect decision-required findings and ask the user
in one grouped message. Log the review via `log-issue.sh` as
`agent:claude (peer review)` with source `peer-review` — one summary entry:
reviewer count, findings, what changed — and move surviving risks into the
`issues.md` Risks register.

### Stage 6 — Plan Delivery

1. Finalize `overview.md` — it is the approval artifact; make sure
   Alternatives, Scope, and Key risks reflect the post-review state.
2. Present to the user: the overview content (or its highlights) plus bundle
   paths. Ask for approval; on approval set overview status to `approved`.
3. Emit the **handoff prompt** — the user will paste this into a fresh
   session, so it must stand alone:

```text
Implement the plan-t3 bundle at ~/.agents/plans/<repo>/t3/<slug>/ (invoke the
plan-t3 skill in implement mode). Read plan.md fully before writing code,
work the deliverables in order, track progress in deliverables.md, and log
any plan gaps or deviations in issues.md.
```

## Implement mode

For the fresh session executing an approved bundle:

1. **Locate** the bundle (path from the handoff prompt, else
   `ls ~/.agents/plans/<repo>/t3/`; ask if multiple match).
2. **Load** `plan.md` in full, then `deliverables.md` and `issues.md`. Honor
   the Implementor instructions section in `plan.md` — it is the contract.
3. **Work deliverables in order.** Tick tasks and update the status board in
   `deliverables.md` as you go; set `overview.md` status to `in-progress` on
   start, `done` when everything is complete.
4. **`plan.md` is frozen.** When reality disagrees with it, log the gap and
   the resolution you chose via `log-issue.sh` with the source that raised it
   (`self` for implementor self-review). Silent deviation is the failure mode
   this whole structure exists to prevent. If the gap is big enough to change
   scope, stop and tell the user — that's a plan-mode revision, not an
   implement-mode judgment call.
5. Between sessions, `deliverables.md` + `issues.md` are the resume state; a
   later agent (or you, after compaction) re-enters at step 1.

## Scope boundary

Plan mode produces and maintains one bundle per effort; it does not write
product code. This skill supersedes `bigplan` for new plans — never create
`*-bigplan.md` files; if the user points at an existing bigplan, offer to
migrate it into a bundle. If a brief turns out to be too small to warrant
this pipeline — one contained change, no cross-cutting concerns — say so
before spending the tokens, and let the user decide how to proceed.

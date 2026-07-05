---
name: plan-t1
description: Fast, lightweight planning for contained work — small features, focused fixes, single-subsystem changes needing a plan but not a heavyweight one. Produces one plan-plus-deliverables file under ~/.agents/plans/<repo>/t1/, and the planner often implements it in the same session. Use whenever the user says "plan t1", "t1 plan", asks for a quick/light/small plan, or wants to implement or resume an existing plan-t1 file. Not for long-term efforts, large refactors, or work with many cross-cutting concerns.
---

# Plan T1

For contained work with fast turnaround — a small feature, a
focused fix, a change inside one subsystem.

Two facts shape everything here:

1. **One file.** Plan, deliverables checklist, and log live in a single
   markdown file. The user approves the plan in chat.
2. **The planner may be the implementor.** If planning left enough context
   headroom, keep going and implement in the same session. The file still
   matters — it survives compaction, and a fresh session can pick it up.

If planning reveals the work is bigger than it looked — multiple subsystems,
real cross-cutting risk, deliverables multiplying — stop and tell the user
the brief has outgrown this skill's remit. How to plan it instead is the
user's call; don't stretch the single-file format to cover it.

## The plan file

Plans live **outside the repo** at `~/.agents/plans/<repo>/t1/<slug>.md`
(overridable via `PLAN_T1_ROOT`) so they can never be accidentally
committed. Create with the bundled script — never hand-roll the file:

```bash
scripts/init-plan.sh <slug> --title "Human Title"
```

(Path relative to this skill directory; slug is kebab-case, 1-3 words.) The
script derives `<repo>` from the git root, seeds the file from
`templates/plan.md`, never overwrites, and prints the path. Existing plans:
`ls ~/.agents/plans/$(basename "$(git rev-parse --show-toplevel)")/t1/`.

## Plan mode

Five stages, in order. Run `init-plan.sh` after the grill, once the effort
has a name and scope.

### 1. Context gathering

Even light plans fail by searching too narrowly. List the angles the work
touches (entry point, adjacent callers, config, tests, prior art), then
spawn **one or two Explore sub-agents** to cover them — digests back, not
file dumps. For a genuinely tiny surface, direct reads are fine, but check:
_do I know where the change lives, what touches it, and how similar changes
were done?_ Any "no" gets a sub-agent before proceeding.

### 2. Grill

Invoke the `grill-me` skill for the judgment calls exploration can't settle:
scope boundary, terminology, need-vs-want. Briefs for contained work are
often already crisp — skipping the grill is fine, but say so with a
one-line reason so the user can override.

### 3. Solution exploration

Sketch the viable approaches — often two, sometimes only one honest option.
Then the grug pass: spawn a sub-agent with the candidate sketches and the
instruction to read `~/.agents/skills/grugbrain/SKILL.md` and apply it —
where does the complexity demon hide, what is the boring path. The
sub-agent keeps grugbrain's content (and its voice) out of your window,
which matters here since you may implement in this same session. Light work
is where overbuild sneaks in easiest, precisely because nobody is
reviewing. Present your recommendation and get the user's pick if there's a
real choice.

### 4. Plan writing

Fill the plan file. The standard to hit:

- Context and Approach written as settled fact — executable by a fresh agent
  even if you expect to implement it yourself, because compaction or an
  interrupted session turns _you_ into the fresh agent.
- Deliverables are vertical slices with concrete acceptance criteria; often
  just one or two for a t1.
- Sweep for research markers ("TBD", "unclear", "figure out later"): resolve
  them by reading code now, or surface them to the user. Hedges don't ship
  in a plan file.

### 5. Delivery

Present the plan briefly (approach, deliverables, verification) and get the
user's go-ahead. Then the context call:

- **Healthy headroom** → offer to implement now, in this session.
- **Planning ate the window** (long exploration, big grill, many files read)
  → emit the handoff prompt instead:

```text
Implement the plan-t1 file at ~/.agents/plans/<repo>/t1/<slug>.md (invoke
the plan-t1 skill in implement mode). Read it fully before writing code,
tick tasks as you complete them, and log deviations in its Log section.
```

Be honest in this call — a cramped implementation session is worse than a
paste. When unsure, say which way you lean and let the user pick.

## Implement mode

Whether same-session or fresh:

1. **Locate** the file (handoff path, else `ls ~/.agents/plans/<repo>/t1/`;
   ask if multiple match) and read it fully.
2. Set Status to `in-progress`. Work deliverables in order, ticking tasks as
   they complete.
3. When reality disagrees with the plan, prepend a dated `Log` entry
   (`- **YYYY-MM-DD — agent:claude** — ...`) with the gap and the resolution
   you chose — no silent deviation. A gap big enough to change scope goes to
   the user instead.
4. Run the Verification section, then set Status to `done`.

## Scope boundary

Plan mode produces and maintains one plan file per effort — the single file
is the format, never bolt extra files onto it. Implementation happens only
after the user's go-ahead in Delivery (or when invoked in implement mode).
Work that no longer fits one file is outside this skill's remit: surface
that to the user rather than working around it.

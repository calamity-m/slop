---
name: spec
description: Write an engineering-focused PRD/spec that defines the problem, testable requirements, solution design, edge cases, and acceptance criteria for a feature or system change. Use whenever the user asks for a spec, PRD, requirements doc, design doc, or wants to pin down what to build and what "done" means before any implementation planning. Not for implementation task lists or work breakdowns.
disable-model-invocation: true
---

# Spec

Produces a single-file engineering spec: the durable record of what to
build, why, and how done is verified. A spec is upstream of any
implementation plan — it defines outcomes and the selected solution shape,
never tasks. If the user asks for a task breakdown or step-by-step
implementation plan, that exceeds this skill's remit: say so and let the
user decide how to plan it.

The bar for the finished document: an engineer who wasn't in the
conversation can review the approach and spot flaws, and someone who didn't
build the feature can verify the acceptance criteria. Every requirement is
observable; every open question is either resolved or listed in Open
questions with an owner.

## The spec file

Specs live **in the repo** at `docs/specs/<slug>.md` — they are review
artifacts meant to be committed and to outlive the work, so they never go
in temp dirs or gitignored areas. Create with the bundled script — never
hand-roll the file:

```bash
scripts/init-spec.sh <slug> --title "Human Title"
```

(Path relative to this skill directory; slug is kebab-case, 1-3 words.) The
script resolves the path from the git root, seeds the file from
`templates/spec.md`, never overwrites, and prints the path. Existing specs:
`ls docs/specs/`.

## Workflow

Four stages, in order. Run `init-spec.sh` once the effort has a name.

### 1. Context gathering

A spec written from assumptions gets its Background and Design sections
wrong, and those errors compound into every plan derived from it. List the
angles the change touches (affected subsystems, current behavior, adjacent
consumers, prior art, existing constraints like performance budgets or
compatibility promises), then spawn **one or two Explore sub-agents** to
cover them — digests back, not file dumps. For a genuinely tiny surface,
direct reads are fine, but check: _do I know how the affected systems behave
today, and what hard constraints the design must live within?_ Any "no"
gets a sub-agent before drafting.

### 2. Grill

Invoke the `grill-me` skill for the judgment calls exploration can't
settle: problem framing, who the user actually is, scope boundary,
need-vs-want, what "done" means. Specs suffer most from an unexamined
problem statement — everything downstream inherits it. If the brief is
already crisp, skipping the grill is fine, but say so with a one-line
reason so the user can override.

### 3. Draft

Fill the spec file. The standard to hit per section:

- **Problem / Goals / Non-goals** — outcomes, not solutions. Goals are
  measurable; non-goals name what a reader might reasonably assume is
  included but isn't.
- **Background & constraints** — settled fact from stage 1, not conjecture.
  If you didn't verify it in the repo or with the user, it doesn't go here.
- **Requirements** — numbered FR-n/NFR-n, one observable behavior per line,
  MUST/SHOULD deliberately chosen. Numbers are stable: mark dropped ones
  "(dropped)" rather than renumbering, so reviews and acceptance criteria
  keep pointing at the right thing.
- **Design** — the selected solution and the general control flow per
  significant behavior (trigger → steps → outcome). Deep enough to review
  the approach, shallow enough that it never reads as a task list: name
  services, modules, data shapes, and interfaces, but stop short of
  file-level edit instructions.
- **Edge cases & failure modes** — input/state → expected behavior. Write
  these while drafting Design, not after: each control flow's unhappy paths
  land here.
- **Acceptance criteria** — given/when/then checks, each mapped to a
  requirement number. If a requirement has no criterion, either the
  requirement isn't testable (rewrite it) or the criterion is missing.

Sweep before presenting:

- Research markers ("TBD", "unclear", "figure out later"): resolve them by
  reading code now, ask the user, or move them into Open questions with an
  owner and what they block. Hedges don't ship anywhere else in the file.
- Template scaffolding: every `<...>` placeholder must be gone — replaced
  with real content, or deleted if it was only instructional.

### 4. Review

Present the spec briefly in chat — problem, the requirement list, the
selected design in a sentence or two, and any open questions — and point
the user at the file. Iterate on their feedback in the file, not in chat
prose. Status transitions are the user's call: set `in-review` when they
start reviewing, `accepted` only when they say so; `accepted` requires an
empty Open questions section. A spec that is later replaced gets
`superseded`, not deleted.

## Scope boundary

This skill produces and maintains one spec file per effort. It does not
break work into tasks, estimate effort, or implement anything — when the
user wants those, surface that the spec is done and the next step is
theirs to choose.

# Plan: {{TITLE}}

Audience: a FRESH implementation agent with zero conversation context — treat
them as a junior engineer who executes instructions literally and improvises
badly wherever the plan is silent. Assume the reader knows nothing that is
not written here or discoverable in the repo; every judgment call is already
made, and every task is an imperative naming real files and real changes.
More instruction is better.

- **Repo**: {{REPO}}
- **Bundle**: `{{BUNDLE}}`
- **Created**: {{DATE}}

## Implementor instructions

You are implementing this plan in a fresh session. Before writing any code:

1. Read this file fully, then `deliverables.md` and `issues.md` in this directory.
2. Work deliverables in order unless a dependency note says otherwise.
3. Track progress in `deliverables.md` — tick tasks as you complete them and
   date each deliverable's start/finish.
4. When you hit something this plan got wrong, ambiguous, or missing: log it
   in `issues.md` (use `~/.agents/skills/plan-t3/scripts/log-issue.sh` with
   `source:self` if present, otherwise add a dated entry to the top of its
   Log section using `- **YYYY-MM-DD — agent:<name> - source:self** - ...`),
   decide the smallest reasonable resolution, and record what you chose. Do
   not silently deviate.
5. Update `overview.md` status to `in-progress` when you start and `done` when
   every deliverable is complete.

## Context

<Everything the fresh agent must know before touching code: how the relevant
subsystems work today, established conventions to follow, terminology, prior
art in the repo. Written as settled fact — no open questions here.>

## Design

<The chosen approach in technical depth: data shapes, interfaces, expected
code paths (control-flow pseudo-code for each significant behavior), and
architecture/infrastructure design where the work touches it — component
boundaries, data flow between systems, deployment/config/migration shape.
Name real files, functions, and commands.>

### Critical files

- `path/to/file` — <role in this change>

### Gotchas

- <non-obvious thing the implementor will trip over>

## Deliverables

Vertical slices of value, each independently verifiable. Numbers are stable:
mark dropped ones "(dropped)" rather than renumbering. The checklist copies
of these live in deliverables.md — this section carries the full description,
constraints, and acceptance criteria.

### Deliverable 1. <short name>

<What it produces, why it matters, constraints, decisions already made.>

**Acceptance**: <concrete, checkable done-state — the command to run, the
behavior to observe, the test that must pass.>

**Tasks**: each task is an imperative naming the file (and function/symbol
where one applies) and the exact change, and ends with a verify step. A task
that requires the implementor to decide anything is not done being written.

1. <imperative change naming file/function> — verify: <command or observation>
2. <imperative change naming file/function> — verify: <command or observation>

### Deliverable 2. <short name>

<...>

## Verification

<How the implementor proves the whole effort works, beyond per-deliverable
acceptance: test commands, manual checks, rollout/rollback notes.>

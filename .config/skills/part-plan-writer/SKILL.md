---
name: part-plan-writer
description: Draft and maintain implementation plans that are split into a fixed number of numbered parts with trackable progress. Use when the user wants a feature plan, rollout plan, migration plan, or refactor plan broken into X parts, wants a shared PLAN_CONTEXT.md plus per-task plan files, or wants living planning docs that must be updated during implementation.
---

# Part Plan Writer

Create one shared planning context file and one task plan bundle with numbered part files.

Keep the workflow simple: clarify the task, choose a sane part count, scaffold the files, replace placeholders with repo-specific detail, run the review passes, and keep the docs current while work is happening.

## Workflow

1. Read only the repo context needed to understand the task.
2. Clarify scope, constraints, acceptance criteria, and the desired number of parts.
3. If the user does not specify the part count, choose a small count that matches the work. Prefer 2-5 parts.
4. Create or preserve the shared `PLAN_CONTEXT.md` file with:

```bash
python3 <skill-dir>/scripts/init_plan_bundle.py --repo-root <repo-root> --title "<title>" --parts <count>
```

5. If the user already knows the slug or part names, pass them:

```bash
python3 <skill-dir>/scripts/init_plan_bundle.py \
  --repo-root <repo-root> \
  --title "<title>" \
  --slug <slug> \
  --parts <count> \
  --part-name "<part 1>" \
  --part-name "<part 2>"
```

6. Replace placeholders in `plans/<slug>/README.md` and each `part-*.md` file with concrete repo-specific content.
7. Validate the bundle structure with:

```bash
python3 <skill-dir>/scripts/validate_plan_bundle.py --repo-root <repo-root> --bundle plans/<slug>
```

8. Run the review loop on every substantive plan. Use fresh no-context sub-agents. Pass raw artifacts, not your conclusions.
9. Update `plans/<slug>/README.md` after each review pass. Record findings, accepted or rejected changes, and the resulting review status.
10. If implementation starts from the plan, keep the plan files alive:
   - update the active part file after material progress, discoveries, validation results, or scope changes
   - update the task `README.md` when part status, sequencing, blockers, or acceptance changes
   - do not leave important decisions only in chat

## Required Review Passes

Every substantive plan should go through these four passes before it is treated as ready:

1. Architecture alignment review
2. Extensibility and prototype integration review
3. Simplicity review
4. Related work explorer review

Start each task README with `Review status: draft`.

Move to `Review status: in-review` while the passes are running.

Move to `Review status: reviewed` only after all required passes are complete and the plan files have been updated.

If sub-agents are unavailable, set `Review status: blocked-no-subagents` and say the plan did not receive the full review loop.

## Reviewer Instructions

### 1. Architecture Alignment Review

- Read the relevant `ARCHITECTURE.md` document if one exists.
- Verify that the planned implementation matches the repository architecture and stated boundaries.
- Flag places where the plan cuts across layers, bypasses conventions, or introduces a shape the repo does not already support.
- Prefer an `explorer` sub-agent when the architecture knowledge is mostly in repo files.

If no `ARCHITECTURE.md` exists, downgrade this pass to the strongest available architecture evidence from repo docs and code, and record that downgrade in the README.

### 2. Extensibility And Prototype Integration Review

- Read the plan and the code it expects to change.
- Check whether the proposed solution is durable if it is meant to be permanent.
- Check whether prototype or temporary work is clearly isolated if it is intentionally temporary.
- Flag plans that accidentally turn prototypes into long-term architecture or that hard-code short-term assumptions into permanent interfaces.

### 3. Simplicity Review

- Review the plan for over-engineering, abstraction creep, and needless complexity.
- Prefer the smallest plan that still solves the real problem.
- Remove speculative flexibility unless the repo already needs it.

### 4. Related Work Explorer Review

- Use an `explorer` sub-agent.
- Search the repo for related features, adjacent code paths, partial refactors, similar workflows, or existing helpers.
- Verify whether the new plan is aligned with those areas or whether it creates a conflicting second pattern.
- Call out code that should probably be reused, updated, or explicitly left alone.

## Review Recording Rules

- Record findings in `plans/<slug>/README.md`, not only in chat.
- Keep `Review Findings` short and concrete.
- Record accepted and rejected recommendations in `Decision Log`.
- If a review pass changes the scope or sequencing, update the part tracker and the affected part files immediately.
- If the plan is tiny and you intentionally skip the review loop, say so plainly and record that choice.

## Part Count Guidance

- Prefer 2-5 parts for most work.
- Use 1 part only when the user explicitly wants the format for a small task.
- Use more than 5 parts only when the work naturally splits into distinct streams or milestones.
- Make each part independently meaningful and verifiable.

## File Layout

The default output layout is:

- `PLAN_CONTEXT.md`
- `plans/<slug>/README.md`
- `plans/<slug>/part-01*.md`
- `plans/<slug>/part-02*.md`

Treat `PLAN_CONTEXT.md` as the repo-wide contract for how planning docs should behave.

Treat `plans/<slug>/README.md` as the canonical task summary and cross-part tracker.

Treat each part file as the working document for one concrete slice of the task.

## Writing Rules

- Write concrete, repo-specific plans. Remove placeholders before considering the plan done.
- Keep statuses explicit: `planned`, `in-progress`, `blocked`, or `done`.
- Keep review statuses explicit: `draft`, `in-review`, `reviewed`, or `blocked-no-subagents`.
- Put validation in every part file.
- End every part with the next handoff, even if the handoff is "nothing left".
- If the task is too small for this structure, say so instead of forcing ceremony.

## Resources

### scripts/

- `scripts/init_plan_bundle.py`: create `PLAN_CONTEXT.md`, a task bundle, and numbered part files.
- `scripts/validate_plan_bundle.py`: validate the shared context, task README, and part file structure.

### assets/

- `assets/PLAN_CONTEXT.template.md`: shared repo-wide planning context template.
- `assets/TASK_README.template.md`: task summary and cross-part tracker template.
- `assets/PART.template.md`: per-part working document template.

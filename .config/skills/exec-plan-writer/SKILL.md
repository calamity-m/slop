---
name: exec-plan-writer
description: Draft, revise, and maintain concrete ExecPlans / execution plans for real tasks using the repository's `PLANS.md` standard, iterative no-context sub-agent reviews, and a final `AGENTS.md` adherence pass. Use when the user wants an ExecPlan, execution plan, implementation plan, design-and-execution document, or a living plan for a complex feature, refactor, migration, or multi-step task.
---

# ExecPlan Writer

Draft a real ExecPlan file for a specific task, then harden it through multiple fresh-thread reviews before treating it as ready.

This skill is not the setup skill. It assumes the repo either already has `PLANS.md` / `AGENTS.md` or can at least borrow the bundled template while drafting.

## Workflow

1. Read `AGENTS.md` and the repository's shared `PLANS.md` file if they exist.
2. If the repo has no shared `PLANS.md`, create one from the bundled template or stop and tell the user to run `$exec-plan-setup` first. Do not draft against an implicit or unwritten standard.
3. **Discovery & Clarification** — Before drafting anything, engage the user in a focused conversation to surface missing context, resolve ambiguity, and agree on requirements. See the dedicated section below for the rules governing this phase. Do not skip it.
4. Gather only the repo context needed to write the plan: the task, relevant files, architectural constraints, and validation commands.
5. Create the first plan draft with:

```bash
python3 <skill-dir>/scripts/new-execplan.py --repo-root <repo-root> --plans-path <plans-path> --output <execplan-path> --title "<title>"
```

6. Replace the template placeholders with real repository-specific content. Fill in the `Requirements` section with the high-level requirements synthesized from the discovery conversation.
7. Validate the structure with:

```bash
python3 <skill-dir>/scripts/validate-execplan.py --repo-root <repo-root> --plans-path <plans-path> --execplan <execplan-path>
```

8. Run the required review loop using fresh no-context sub-agents.
9. After every review pass, update the ExecPlan itself. Treat the plan as the living record.
10. Run the final `AGENTS.md` adherence review and update the plan again before finishing.

## Discovery & Clarification (Mandatory)

Before writing a single line of the ExecPlan, the agent must engage the user in a structured discovery conversation. The goal is to arrive at a shared, explicit understanding of requirements before any drafting begins.

### Rules

- **Always ask questions first.** Never jump straight to drafting. Even when the user's prompt seems clear, probe for what might be missing.
- **Assume the user has forgotten something.** Most initial requests omit constraints, edge cases, affected systems, or acceptance criteria that only surface when asked about directly. Actively look for these gaps.
- **Clarify language that invites assumptions.** Vague verbs ("improve", "clean up", "handle"), unqualified scope ("the API", "the tests"), and implicit priorities ("make it better") must be pinned down before they become plan assumptions.
- **Surface the "why".** Ask what problem this solves, who it affects, and what success looks like from the user's perspective. Plans written without understanding intent drift into busywork.
- **Propose and confirm requirements.** After the conversation, synthesize a short list of high-level requirements and present them to the user for confirmation before drafting. These requirements become the `## Requirements` section of the ExecPlan.

### What to ask about

- **Scope boundaries**: What is in scope and what is explicitly out of scope?
- **Constraints**: Performance budgets, backward compatibility, deployment windows, feature flags, security considerations.
- **Affected systems**: Which services, modules, or teams are touched? Are there downstream consumers?
- **Acceptance criteria**: How will the user know this is done? What observable behavior proves success?
- **Prior art**: Has this been attempted before? Are there related issues, RFCs, or conversations?
- **Risk tolerance**: Is this a "move fast" situation or a "measure twice, cut once" situation?

### When to stop asking

Stop when you can write down a requirements list that the user agrees with. If the user explicitly says "just draft it, I'll correct as we go", respect that — but still fill in the `## Requirements` section with your best-effort synthesis and flag which items are assumptions.

## Non-Negotiable Review Rules

- Every substantive ExecPlan must go through multiple review iterations.
- Every review sub-agent must be fresh-thread and no-context: use `fork_context: false`.
- Pass raw artifacts, not your conclusions. Give each reviewer only the task summary, the current ExecPlan, `AGENTS.md`, `PLANS.md`, and any raw repo files they need.
- Do not substitute local self-review for the required reviewer passes.
- After each review, revise the plan before launching the next reviewer.
- Record important reviewer-driven changes in `Decision Log`, `Surprises & Discoveries`, `Progress`, or `Outcomes & Retrospective`.
- Start every new plan with `Review status: draft`.
- Change the status to `Review status: reviewed` only after the required review loop and final `AGENTS.md` adherence pass are complete.
- If sub-agents are unavailable, set `Review status: blocked-no-subagents`, stop, and say this skill cannot guarantee the required review loop.

## Required Reviewers

Every plan must use these reviewers:

1. Senior architect reviewer
2. Simplicity reviewer
3. Final `AGENTS.md` adherence reviewer

The senior architect reviewer should focus on big-picture design, sequencing, internal and external APIs, interfaces, rollback, migration, operability, and missing constraints.

The simplicity reviewer should carry the same instincts as `grug-review`: complexity is usually the bug, abstractions must justify themselves, locality beats purity, and a simpler plan is better if it still works.

The final `AGENTS.md` adherence reviewer must check that the plan respects repository tastes such as refactoring posture, coding style, testing expectations, validation commands, and local conventions.

## Complexity-Based Review Depth

Use [references/review-rubric.md](./references/review-rubric.md) to choose the minimum number of passes.

Minimum review depth:

- Low complexity: architect -> simplicity -> `AGENTS.md` adherence
- Medium complexity: architect -> simplicity -> one targeted follow-up pass -> `AGENTS.md` adherence
- High complexity: architect -> simplicity -> targeted risk reviewer -> architect re-review -> simplicity re-review -> `AGENTS.md` adherence
- Very high uncertainty or cross-cutting change: keep iterating until no unresolved high-severity findings remain; do not stop at fewer than six substantive passes

Targeted reviewers are chosen from the risk profile: internal or external API/contracts, migration/rollback, validation/operations, or dependency/interface drift.

## Review Loop Mechanics

For the reviewer personas and prompt shapes, read:

- [references/architect-review.md](./references/architect-review.md)
- [references/simplicity-review.md](./references/simplicity-review.md)
- [references/agents-adherence.md](./references/agents-adherence.md)
- [references/review-rubric.md](./references/review-rubric.md)

Prompt each reviewer with only:

- the user task in one paragraph
- the current ExecPlan file
- `AGENTS.md`
- shared `PLANS.md`
- a small set of directly relevant repository files if needed

Do not pass previous reviewer summaries unless that exact text has already been incorporated into the plan itself.

## How To Update The Living Plan

After every review pass:

- update `Progress` with the review milestone
- add new constraints or unexpected findings to `Surprises & Discoveries`
- record accepted or rejected reviewer recommendations in `Decision Log`
- refine `Plan of Work`, `Concrete Steps`, `Validation and Acceptance`, and `Idempotence and Recovery` to close the gaps that the reviewer found
- update the `Review status` line if the plan moved from draft to reviewed, or from draft to blocked

Do not keep review feedback in a side channel only. If it matters, it belongs in the ExecPlan.

## Fallbacks

- If `AGENTS.md` is missing, do a local conventions review from the available repo docs and say that the final adherence pass was downgraded.
- If `PLANS.md` is missing, create it from the bundled template or stop and direct the user to `$exec-plan-setup`.
- If the task is simple enough that an ExecPlan would be overkill, say so plainly instead of forcing ceremony.

## Resources

### scripts/

- `scripts/new-execplan.py`: create a starter ExecPlan file from the bundled template.
- `scripts/validate-execplan.py`: verify that a concrete ExecPlan contains the required sections and references the repository's `PLANS.md`.

### assets/

- `assets/EXECPLAN.template.md`: starter ExecPlan template with the required living-document sections.

### references/

- `references/review-rubric.md`: complexity tiers, minimum review depth, and targeted reviewer choices.
- `references/architect-review.md`: senior architect reviewer persona and prompt shape.
- `references/simplicity-review.md`: simplicity-first reviewer persona derived from the grug-review posture.
- `references/agents-adherence.md`: final reviewer checklist for repository-specific rule adherence.

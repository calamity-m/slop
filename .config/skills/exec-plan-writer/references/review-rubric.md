# Review Rubric

Use this rubric to decide how many review passes the ExecPlan needs before it is ready.

## Low Complexity

Use this when all of these are true:

- one subsystem or narrow slice of the repo
- no migration or rollback risk
- no internal or external API change
- low ambiguity

Minimum passes:

1. Senior architect reviewer
2. Simplicity reviewer
3. `AGENTS.md` adherence reviewer

## Medium Complexity

Use this when one or two of these are true:

- multiple files or modules must move together
- there is moderate ambiguity
- testing or validation is non-trivial
- there is some sequencing risk

Minimum passes:

1. Senior architect reviewer
2. Simplicity reviewer
3. One targeted follow-up reviewer based on the biggest remaining risk
4. `AGENTS.md` adherence reviewer

## High Complexity

Use this when any of these are true:

- multiple subsystems or teams of concern
- internal or external interfaces, migrations, or rollback concerns
- operational or observability implications
- significant uncertainty about sequencing or dependencies

Minimum passes:

1. Senior architect reviewer
2. Simplicity reviewer
3. Targeted risk reviewer
4. Senior architect re-review after updates
5. Simplicity re-review after updates
6. `AGENTS.md` adherence reviewer

## Very High Uncertainty

Use this when the task involves broad refactors, migrations with unclear edges, concurrency or distributed behavior, or major product uncertainty.

Rules:

- keep iterating until there are no unresolved high-severity findings
- run at least six substantive review passes before the final handoff
- add prototype or proof-of-concept milestones if feasibility is still in doubt

## Targeted Risk Reviewers

Choose the extra reviewer based on the dominant unresolved risk:

- Interface and compatibility reviewer: internal or external APIs, signatures, contracts, schema drift, and compatibility guarantees
- Migration and rollback reviewer: data changes, backfills, cutovers, downgrade paths
- Validation and operations reviewer: runtime checks, monitoring, deploy safety, observability
- Performance and scaling reviewer: if the plan makes performance claims or changes hot paths

Use the same fresh-thread pattern as the other reviewers. Pass only the raw plan, repo standards, and a prompt that narrows the lens to the chosen risk area.

## Stop Condition

Do not stop the review loop just because every required role has spoken once. Stop when:

- the current complexity tier's minimum passes are complete
- the plan has no unresolved major design gaps
- the validation path is concrete
- the final `AGENTS.md` adherence pass is complete

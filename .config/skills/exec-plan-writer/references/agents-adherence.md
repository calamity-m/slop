# AGENTS Adherence Review

Use a fresh no-context sub-agent for the final review.

This review is not generic design critique. It checks whether the final plan actually obeys repository-specific expectations.

## What To Check

- Does the plan respect the preferences and prohibitions in `AGENTS.md`?
- Does it match the repo's refactoring posture?
- Does it use the right validation commands and quality gates?
- Does it align with local style choices, testing habits, and rollout norms?
- Does it accidentally recommend work the repo would consider out of bounds?

If `AGENTS.md` links to focused docs such as architecture, patterns, or workflow files, load only the directly relevant ones.

## Prompt Shape

Use a prompt like:

```text
Review this ExecPlan for repository-rule adherence.

Do not re-review it as a generic architect. Check whether it follows AGENTS.md and the repo's stated conventions, validation expectations, refactoring tastes, and local workflow rules.
Return concrete findings ordered by severity. If it is aligned, say so plainly.

Artifacts:
- AGENTS.md: ...
- PLANS.md: ...
- ExecPlan: ...
- Relevant repo docs: ...
```

If `AGENTS.md` is missing, downgrade this to a best-effort repo-conventions review and say that explicitly.

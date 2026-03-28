# ExecPlan Rules

This skill is based on OpenAI's cookbook article:

- `https://developers.openai.com/cookbook/articles/codex_exec_plans`

## Core Ideas

- Use an ExecPlan for complex features, significant refactors, and other long-running work.
- Treat the plan as a living document, not a one-time spec.
- Make the plan fully self-contained so a novice can continue from only the repository and the plan file.
- Define success as observable behavior, not just code changes.
- Keep the plan updated with progress, design decisions, discoveries, and retrospective notes.

## Required Shared Setup

The repository should have:

- `AGENTS.md` guidance telling the agent when to use ExecPlans and where the shared `PLANS.md` lives.
- A shared `PLANS.md` file that defines the ExecPlan standard for the repo.

Optionally, the repo can also contain concrete ExecPlan files such as `plans/add-auth-refresh.md`.

## Required Sections In A Concrete ExecPlan

Every concrete ExecPlan should keep these sections:

- `Progress`
- `Surprises & Discoveries`
- `Decision Log`
- `Outcomes & Retrospective`

The official skeleton also expects:

- `Purpose / Big Picture`
- `Context and Orientation`
- `Plan of Work`
- `Concrete Steps`
- `Validation and Acceptance`
- `Idempotence and Recovery`
- `Artifacts and Notes`
- `Interfaces and Dependencies`

## Local Path Choice

The cookbook example shows `.agent/PLANS.md` in `AGENTS.md`.

This skill defaults to root-level `PLANS.md` because:

- it is easier to discover
- it avoids creating a new hidden convention in repos that do not already use `.agent/`
- it keeps the reference path short and obvious for humans and agents

If the repo already uses `.agent/PLANS.md`, or the user explicitly wants that layout, keep it.

## Local AGENTS.md Snippet

This skill uses a short rule like:

```md
## ExecPlans

When writing complex features or significant refactors, use an ExecPlan (as described in PLANS.md) from design to implementation.
```

The exact path should match the chosen `PLANS.md` location.

## Why The Templates Exist

The templates in `assets/` are not a substitute for repo-specific thinking. They exist so the agent does not have to reconstruct the cookbook article every time. After bootstrapping, adjust only the path references and any clearly repo-specific terminology.

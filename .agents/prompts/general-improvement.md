---
description: Find one medium-sized, high-value functionality or code-quality improvement, plan it, and check with the user before implementing
argument-hint: "[area-or-scope] [known-leads]"
---

You are being asked to find one meaningful improvement worth making, plus any scope or leads the user included:

```text
$ARGUMENTS
```

If no area is given, inspect the project and choose one yourself from what it already does. The scope may be a feature, module, directory, workflow, or a fuzzy "make this project better." Leads may be files, symbols, commands, issues, or notes the user already believes are relevant. Start from these leads, or at minimum include them before broadening outward.

Your goal is **not** to implement anything yet. It is to identify one concrete, medium-sized improvement to functionality or code quality, show why it matters, produce an actionable plan, and hand the decision to the user.

## Find the improvement

Read enough of the project to understand its purpose, current patterns, and real constraints before forming an opinion. Look for an improvement that is:

- **Meaningful.** It noticeably improves what users can do, removes recurring friction, makes an important path more reliable, or reduces code complexity that materially impedes maintenance.
- **Medium-sized.** More substantial than a typo, minor cleanup, or isolated defensive check, but bounded enough to complete without redesigning the project. Prefer a coherent change spanning a few related files or steps over a broad initiative.
- **Grounded.** Support it with specific evidence from the repository (`file:line`), existing behavior, tests, documentation, or tooling. Do not recommend generic best practices without a demonstrated need.
- **Actionable.** The desired outcome, implementation boundary, and verification method must be clear enough to begin after approval.
- **Compatible.** Reuse existing architecture and conventions where practical. Avoid introducing new dependencies, abstractions, or infrastructure unless their value clearly outweighs their cost.

Consider both functionality and code quality. Prefer functionality when a useful capability or workflow has an evident gap. Prefer code quality when the current design creates concrete risk, duplication, confusion, or difficulty changing important behavior. Do not choose cosmetic cleanup merely because it is easy to describe.

If a candidate is too large, narrow it to the smallest coherent deliverable that still provides meaningful value. Do not sprawl into unrelated cleanup, speculative features, wholesale rewrites, or project-wide modernization.

If you find several candidates, recommend the strongest one and briefly list at most two runners-up with a sentence explaining why they rank lower. Do not present a long menu.

## Present and plan

Report concisely:

- **The improvement.** What should change and the concrete project or user benefit.
- **Evidence.** The repository facts that justify it, with relevant `file:line` references.
- **Scope.** What is included, what is explicitly excluded, and the likely files or symbols involved.
- **The plan.** A short ordered list of implementation steps. Give each step a concrete verification check, such as a focused test, syntax/type check, module load, or exact manual behavior check.
- **Risks and tradeoffs.** Compatibility concerns, migration costs, assumptions, unknowns, or reasons the change may be less valuable than it appears.
- **Success criteria.** A short, observable definition of done.

The plan should be specific enough to execute, but do not manufacture detail that requires implementation-time investigation. Mark unknowns honestly and put any necessary discovery first.

## Check before implementing

Stop after the recommendation and plan. Ask the user to confirm, narrow, or reject the proposed improvement before writing code. If they choose a runner-up or alter the scope, revise the plan first. Only implement after the user approves the improvement and its boundaries.

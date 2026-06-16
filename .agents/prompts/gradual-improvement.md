---
description: Find one small, high-value improvement to the feature set, plan it, and check with the user before implementing
argument-hint: "[area-or-scope] [known-leads]"
---

You are being asked to find one small improvement worth making, plus any scope or leads the user included:

```text
$ARGUMENTS
```

If no area is given, choose one yourself from what the project already does. The scope may be a feature, a module, a directory, a flow, or a fuzzy "make this better." The leads may be files, symbols, commands, or notes the user already believes are relevant. Start from these leads, or at minimum include them before broadening outward.

Your goal is **not** to implement anything yet. It is to surface a single, small, concrete improvement to the existing feature set, plan it, and hand the decision to the user.

## Find the improvement

Read enough of the code to have facts before opinion. Look for an improvement that is:

- **Small.** One sitting of work. If it needs a big refactor or touches many areas, it is too big — narrow it or pick another.
- **Real.** Grounded in something you actually found (`file:line`), not a generic best-practice you assume applies.
- **Worth it.** It improves the feature set: a rough edge smoothed, a missing-but-obvious capability, a fragile path made robust, a confusing behavior clarified.

Do not sprawl into unrequested cleanup, adjacent features, or wholesale rewrites. Prefer the change that gives the most value for the least disruption.

If you find several candidates, pick the one you'd recommend first and briefly note the runners-up — do not present a long menu.

## Present and plan

Report concisely:

- **The improvement.** One or two lines. What it is and why it's worth doing now.
- **Where.** The files or symbols involved (`file:line`), and whether existing patterns can be reused.
- **The plan.** A short ordered list of steps, each with a concrete verification check (e.g. `bash -n install.sh`, loading a changed module, running the relevant tool).
- **Tradeoffs and unknowns.** Anything that could make this harder than it looks, or any assumption you're making.

## Check before implementing

Stop here and ask the user to confirm before writing any code. If they pick a different candidate, replan for that one. Only implement once the user agrees on the improvement and the plan.

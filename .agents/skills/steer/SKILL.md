---
name: steer
description: Dump a concise handoff doc from a stuck, polluted, or wrong-direction session so a fresh agent can pick up with corrected steering. User-invoked only — do not trigger automatically.
disable-model-invocation: true
---

# Steer

You are at a dead-end, going the wrong way, or the context is too polluted to continue cleanly. Write a compact handoff doc so a fresh agent can take over with correct steering.

## Your job

Extract only what matters from the current session and write it to a file. Do not summarise the whole conversation. Focus on what is broken or stuck and what the next agent needs to avoid or try differently.

## Output file

Write to `.steer/handoff-<YYYYMMDD-HHMMSS>.md` in the repo root, creating `.steer/` if it does not exist. Use the actual current timestamp.

## Handoff doc format

Keep the entire file under 100 lines. Each section has a hard limit — cut to fit.

```markdown
# Steer Handoff

**Timestamp:** <ISO datetime>

## Original prompt
<!-- 1–3 sentences. The user's original request, query, or instruction that started this session — as literally as you can recall it. Not a paraphrase of the goal; the actual starting point. -->

## What was being attempted
<!-- 2–4 sentences max. The goal, not the journey. -->

## Current state
<!-- Bullet list, 6 items max. What exists or changed that the next agent must know about.
     File paths, partial states, commands that ran, side effects. -->

## What went wrong
<!-- 2–4 sentences. The failure mode — not a chronology of attempts. -->

## Dead ends — do not retry these
<!-- Bullet list, 4 items max. Specific approaches that failed and why. -->

## Open unknowns
<!-- Bullet list, 4 items max. Gaps that caused or worsened the failure. -->

## Suggested next approach
<!-- 2–4 sentences or a short bullet list. Only if there is a reasonable lead; omit if genuinely unknown. -->
```

## Rules

- Write only what is directly relevant to the current failure or wrong direction.
- Do not include chat history, attempts that worked, or background context that has not caused problems.
- If a section has nothing to say, write `<!-- none -->` — do not pad it.
- Do not exceed 100 lines total. Cut the least-relevant bullets first if over.
- After writing, print the file path and a one-line summary of what you captured.
- Then tell the user: "Clear context, open a new session, and pass this file with your steering instructions."

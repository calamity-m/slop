---
name: handoff
description: Dump a concise continuation handoff doc from a healthy session so a fresh agent can pick up exactly where this one left off after a context reset. User-invoked only — do not trigger automatically.
disable-model-invocation: true
---

# Handoff

The work is on track, but the context is large or the user wants a clean reset. Write a compact continuation doc so a fresh agent can resume mid-task without re-deriving anything.

## Your job

Capture the working state, not the journey. Do not summarise the whole conversation. The next agent will trust this doc as ground truth: record what is done, what was decided and why, and exactly what to do next. Anything you leave out gets rediscovered at full cost — anything wrong gets trusted.

## Output file

Write to `.agents/handoff/handoff-<YYYYMMDD-HHMMSS>.md` in the repo root, creating `.agents/handoff/` if it does not exist. Use the actual current timestamp.

## Handoff doc format

Keep the entire file under 120 lines. Each section has a hard limit — cut to fit.

```markdown
# Continuation Handoff

**Timestamp:** <ISO datetime>

## Original prompt

<!-- 1–3 sentences. The user's original request that started this session — as literally as you can recall it. Not a paraphrase of the goal; the actual starting point. -->

## Goal

<!-- 1–3 sentences. What "done" looks like, including any success criteria the user stated. -->

## Done and verified

<!-- Bullet list, 8 items max. Work that is complete, with how it was verified
     (test run, command output, manual check). Include file paths. -->

## Current state

<!-- Bullet list, 6 items max. In-flight or partial work the next agent inherits:
     uncommitted changes, half-edited files, running processes, branch state. -->

## Decisions made

<!-- Bullet list, 6 items max. Choices with a one-line why, especially ones the user
     approved or that had rejected alternatives — so the next agent does not relitigate them. -->

## Remaining work

<!-- Ordered list, 8 items max. Concrete next steps in execution order.
     Step 1 should be immediately actionable with no further investigation. -->

## Gotchas and constraints

<!-- Bullet list, 6 items max. Non-obvious things learned the hard way: environment quirks,
     user preferences stated mid-session, things that look wrong but are intentional. -->

## How to verify

<!-- 1–4 lines. The commands or checks that prove the remaining work is done correctly. -->
```

## Rules

- Record only what the next agent needs to continue; skip background that never influenced the work.
- State facts, not narrative — "X is done, verified by Y", not "then I tried".
- Prefer exact paths, commands, and identifiers over descriptions of them.
- If a section has nothing to say, write `<!-- none -->` — do not pad it.
- Do not exceed 120 lines total. Cut the least-relevant bullets first if over.
- After writing, print the file path and a one-line summary of where the work stands.
- Then tell the user: "Clear context, open a new session, and pass this file to continue where we left off."

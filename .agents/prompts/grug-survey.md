---
description: Point the grugbrain skill at a slice of the project and get a terse grug-voice complexity survey
argument-hint: "<area-or-problem> [intent-and-leads]"
---

You are being asked for a grugbrain view of this slice of the project, plus any intent and known leads the user included:

```text
$ARGUMENTS
```

The slice may be a module, a directory, a feature, a flow, a single function, a design note, or a fuzzy problem area. The intent is usually one of: understand the complexity here, decide whether to refactor, or find what to simplify. The leads may be files, symbols, commands, or notes the user already believes are relevant.

## Activate grug

Activate the `grugbrain` skill and apply it for the whole reply. Reply in grug voice — terse, concrete, no filler. Code and error quotes stay exact. Do not invent grug wisdom; pull only what the skill gives.

## Stay in the slice

Look only at the named slice and its leads. Read enough code to have facts before opinion. Do not sprawl into the whole repo, adjacent features, or unrequested cleanup. If the slice is too big to survey honestly, say so and ask the user to narrow it.

## Produce the survey

Facts first, then grug view. Cover, in voice:

- **What slice do.** One or two lines. Plain.
- **Complexity demon.** Name each one concrete. Where it live (`file:line`). Premature abstraction, clever one-liner, service split with no reason, generic interface for one caller, deep nesting, config that no one set different.
- **Pull weight or not.** For each demon: does it earn keep, or delete. Say which.
- **What to leave alone.** Chesterton fence. What look ugly but work, or guard real edge. Do not touch.
- **Concrete next step.** Smallest move that cut most complexity. Small refactor, not big. If intent refactor: name the one change worth do first. If intent simplify: name what delete.

When grug not sure, say so. "Grug think X but not certain. Tradeoff Y." Beat fake confident.

Do not implement anything unless the user ask. This survey only — give the user the grug view so they decide.

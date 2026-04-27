---
name: bigplan
description: Create and maintain a living BIGPLAN.md planning document at the repo root with Plan Overview, Risks, Plan Details (pseudo-code, gotchas, critical files), Deliverables (numbered sub-deliverables with description + checkbox task list), and an Issues scratch area. Use this skill whenever the user wants to scaffold, update, or work against a BIGPLAN, asks for a "big plan" / multi-deliverable plan / living plan document, wants to break a sizeable effort into deliverables with checklists, or refers to "the bigplan" in this repo. Also use it to tick items off, add new deliverables, revise risks, capture gotchas/critical files, or log issues and contention points as work progresses.
---

# BIGPLAN

Maintain a single living planning document — `BIGPLAN.md` at the repo root — that captures the shape of a sizeable piece of work: what it is, what could go wrong, and the discrete deliverables that make it real.

The document is **living**: it is updated as scope shifts, risks materialize, deliverables complete, or new ones emerge. Treat every invocation of this skill as either *creating* the file or *editing it in place* — never start from scratch when one already exists.

## When to create vs. update

1. Check whether `BIGPLAN.md` already exists at the repo root.
2. If it doesn't exist and the user is describing new work → create it from the template below.
3. If it exists → read it first, then make the smallest coherent edit that satisfies the request (tick items, add a deliverable, revise a risk, expand a description). Preserve everything else verbatim.

Don't silently rewrite sections the user didn't ask about. If you spot something stale while making a requested edit, mention it and ask before changing it.

## Document structure

`BIGPLAN.md` always uses this exact skeleton:

```markdown
# BIGPLAN: <short title of the effort>

## Plan Overview

<2-6 sentences. What is this effort, why does it exist, what does "done" look like at the highest level. Avoid restating the deliverables — this is the elevator pitch.>

## Risks

- **<risk name>** — <one or two sentences: what could go wrong, and the mitigation or watch-for signal.>
- **<risk name>** — <...>

## Plan Details

<Free-form technical detail that supports the deliverables — pseudo-code sketches, algorithms, data shapes, gotchas, relevant subsystems. Use subheadings as needed.>

### Critical Files

- `path/to/file.ext` — <why it matters / what role it plays>
- `path/to/other.ext` — <...>

### Gotchas

- <non-obvious thing future-you or another agent will trip over>

### Pseudo-code / Sketches

```text
<rough algorithm or interaction sketch — not real code, just enough to anchor the design>
```

## Deliverables

### Deliverable 1. <short name>

<A paragraph or two describing what this deliverable produces, why it matters, and any constraints or acceptance criteria. Be concrete — name files, systems, or interfaces where it helps.>

- [ ] <first concrete task>
- [ ] <next task>
- [ ] <...>

### Deliverable 2. <short name>

<description>

- [ ] <task>
- [ ] <task>

## Issues

<Scratch area. Agents and humans append findings, contention points, open questions, blockers, or "this looked weird" notes here. Newest at the top. Each entry is dated and signed so the trail is legible.>

- **YYYY-MM-DD — <author/agent>** — <observation, question, or contention point. Link to the relevant deliverable or file when possible.>
```

### Section rules

- **Plan Overview** — keep it short. If you find yourself listing tasks here, move them into a deliverable.
- **Risks** — each risk is a bolded short name plus a sentence or two. Order by severity (worst first). It's fine to have only 2-3 risks; padding with hypotheticals dilutes the list. If a risk is fully mitigated, either delete it or move it under a `### Resolved` subheading at the bottom of the section so the history is preserved.
- **Plan Details** — the technical scratchpad that supports the deliverables. Common subheadings are `### Critical Files`, `### Gotchas`, and `### Pseudo-code / Sketches`, but add or drop subheadings to match the work. Empty subheadings are noise — omit them rather than leaving placeholders. Anything that's *what to build* belongs in a deliverable; this section is *what to know while building it*.
- **Deliverables** — numbered sequentially (`Deliverable 1`, `Deliverable 2`, ...). Numbers are stable: if you remove a deliverable, mark it `### Deliverable N. <name> (dropped)` rather than renumbering, so cross-references in commits and chats keep working. New deliverables go at the end with the next number.
- **Checklist items** — `- [ ]` for open, `- [x]` for done. Keep them small and verifiable. If a task balloons, promote it to its own deliverable.
- **Issues** — always the last section. A reverse-chronological log (newest at top) of findings, contention points, open questions, and "this looks off" notes from agents and humans. Each entry is dated (`YYYY-MM-DD`) and signed (`agent:claude`, a person's name/handle, etc.) so future readers can trace who said what. Don't delete entries when they get resolved — append a follow-up entry noting the resolution. Keep the section flat (no subheadings); if it grows unwieldy, that's a signal to convert recurring issues into deliverables or risks.

## Filling in the template well

The skeleton is only as useful as the content. When drafting or expanding the document:

- **Plan Overview** answers *why* and *what is "done"*. A reader who hasn't been in the conversation should understand the shape of the work in 30 seconds.
- **Risks** are concrete things that could derail the plan — unknowns, dependencies on others, fragile assumptions, performance/scale unknowns. "We might write bugs" isn't a risk. "The third-party API rate-limits at 10 rps and we need 50 rps for the import deliverable" is.
- **Deliverables** are vertical slices of value, not horizontal layers. Prefer "user can log in with email" over "build the auth database table". Each one should be independently demonstrable.
- **Deliverable descriptions** earn their keep by capturing decisions and constraints that would otherwise live only in chat — chosen libraries, file paths, API shapes, acceptance criteria. The checklist is the *how*; the description is the *what and why*.

## Updating in place

When the user asks to update the plan, prefer surgical edits:

- **Tick a task**: change `- [ ]` to `- [x]` on the matching line. Don't reorder.
- **Add a task to a deliverable**: append at the end of that deliverable's checklist.
- **Add a new deliverable**: append at the end of `## Deliverables` with the next sequential number.
- **Revise a risk or description**: edit the prose; if the change is significant, briefly note in your reply what you changed so the user can sanity-check.
- **Add to Plan Details**: drop the new file under `### Critical Files`, the new gotcha under `### Gotchas`, etc. Create a new subheading only if none of the existing ones fit.
- **Log an issue**: prepend a new dated, signed entry at the top of `## Issues`. Don't edit prior entries — add a follow-up entry instead so the trail stays intact.

If the user describes work that's already done in conversation but the plan still shows it open, offer to tick the relevant items rather than doing it unprompted — they may have done it differently than the plan anticipated.

## Scope boundary

This skill produces and maintains `BIGPLAN.md`. It does not write code, run the plan, create separate per-deliverable files, or stand up a multi-doc planning bundle. If the user wants per-part files or a heavier planning structure, point them at `part-plan-writer` instead.

---
name: bigplan
description: Create and maintain a living BIGPLAN.md planning document at the repo root with Plan Overview, Risks, Plan Details (pseudo-code, gotchas, critical files), Deliverables (numbered sub-deliverables with description + checkbox task list), and an Issues scratch area. Use this skill whenever the user wants to scaffold, update, or work against a BIGPLAN, asks for a "big plan" / multi-deliverable plan / living plan document, wants to break a sizeable effort into deliverables with checklists, or refers to "the bigplan" in this repo. Also use it to tick items off, add new deliverables, revise risks, capture gotchas/critical files, or log issues and contention points as work progresses.
---

# BIGPLAN

Maintain a single living planning document — `BIGPLAN.md` at the repo root — that captures the shape of a sizeable piece of work: what it is, what could go wrong, and the discrete deliverables that make it real.

The document is **living**: it is updated as scope shifts, risks materialize, deliverables complete, or new ones emerge. Treat every invocation of this skill as either *creating* the file or *editing it in place* — never start from scratch when one already exists.

## When to create vs. update

1. Check whether `BIGPLAN.md` already exists at the repo root.
2. If it doesn't exist and the user is describing new work → **invoke the `grill-me` skill first** (see "Pre-draft grill" below), then create the document from the template using the resulting Shared Understanding summary.
3. If it exists → read it first, then make the smallest coherent edit that satisfies the request (tick items, add a deliverable, revise a risk, expand a description). Preserve everything else verbatim.

Don't silently rewrite sections the user didn't ask about. If you spot something stale while making a requested edit, mention it and ask before changing it.

## Pre-draft grill

A new BIGPLAN exists to capture sizeable work, and sizeable work is exactly where unspoken assumptions become deliverable-shaped pain. Before drafting, hand off to the `grill-me` skill to reach shared understanding.

The grill should:

1. Do its own pre-flight (read the repo, the README, any linked docs) — do not ask the user things you can answer yourself.
2. Run the question loop until the stopping criteria in `grill-me` are met or the user calls it.
3. Produce the **Shared understanding** summary block.

Use that summary as the source material for the first draft:

- **Goal** seeds the Plan Overview.
- **In scope / Out of scope** shapes the deliverable boundaries.
- **Key terms** flow into the Plan Details, especially as Gotchas if a term has been overloaded historically.
- **Assumptions confirmed** are background facts; do not list them again unless one is load-bearing for a deliverable.
- **Open questions deferred** become Issues entries, dated and signed, so they don't get lost.

Skip the grill **only** when the brief is already crisp (the user has clearly thought it through, scope is explicit, terms are unambiguous). When skipping, say so in your reply with a one-line reason — "brief is clear, skipping grill because X" — so the user can override if they disagree.

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

## Plan Review

Plan review is part of this skill's built-in lifecycle:

- **Always after initial creation**: once you've written the first draft of `BIGPLAN.md`, run a review before presenting the finished plan to the user.
- **On demand**: whenever the user says "review plan", "review the bigplan", "review my plan", or asks for a critical look at the plan.

### Running the review

Spawn 2 sub-agents **simultaneously**. Give each one *only* the current `BIGPLAN.md` content — no conversation history, no project context beyond what's in the file. This isolation is intentional: fresh eyes catch things that context blinds you to.

Before spawning, read `references/adversarial-reviewer.md` and include those full instructions in each sub-agent's prompt, along with which reviewer role they are playing:

- **Reviewer A — Risks & Assumptions**: finds missing or understated risks, hidden assumptions, single points of failure.
- **Reviewer B — Completeness & Scope**: finds uncovered promises, tasks too coarse to act on, missing deliverables, unacknowledged dependencies.

### Merging findings into the plan

Once both reviewers complete, synthesize their outputs:

1. Discard duplicate findings and anything that is genuinely nitpicky or irrelevant given the plan's obvious scope.
2. Split the remaining findings into two buckets:
   - **Unambiguous**: there is one clear fix — add a missing risk, fill in an obvious gap, add a gotcha. Apply these directly to `BIGPLAN.md` without asking.
   - **Requires decision**: the fix involves a real choice — competing approaches, a tradeoff the user needs to weigh in on, or a gap where the right answer isn't obvious from the plan alone.
3. For any decision-required findings, **pause and ask the user before editing**. Present them grouped, concisely:

```
The review found a few things that need your call before I can merge them:

1. **[Short title]** — [One sentence on the problem and why the fix isn't obvious. E.g. "The plan doesn't say whether auth tokens are short-lived JWTs or opaque session tokens — the mitigation strategy differs significantly."] What's your preference?
2. **[Short title]** — ...
```

Wait for the user's answers, then apply their chosen fixes alongside the unambiguous ones.

4. Prepend a review log entry at the top of `## Issues`:

```
- **YYYY-MM-DD — agent:claude (adversarial review)** — Plan reviewed by 2 adversarial sub-agents (Risks & Assumptions, Completeness & Scope). N findings; M merged into plan. <one sentence summary of most significant change, or "No significant gaps found.">
```

Add individual `## Issues` entries only for things that remain unresolved after the user's input — persistent open questions, deferred decisions. Direct edits don't need their own entries; the review log summary is enough.

After all merges are done, briefly tell the user what changed — a 2-3 bullet summary of the most significant findings and how they were addressed. Don't narrate every minor tweak.

## Scope boundary

This skill produces and maintains `BIGPLAN.md`. It does not write code, run the plan, create separate per-deliverable files, or stand up a multi-doc planning bundle. If the user wants per-part files or a heavier planning structure, point them at `part-plan-writer` instead.

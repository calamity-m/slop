# Spec: {{TITLE}}

Audience: engineers who will design and build this, and reviewers deciding
whether it's the right thing to build. Every requirement is testable; every
open question is either resolved or explicitly listed. No implementation
tasks — this document defines done, not how to get there.

- **Repo/System**: {{REPO}}
- **Created**: {{DATE}}
- **Status**: draft _(draft / in-review / accepted / superseded)_

## Problem

<What hurts today, who it hurts, and the evidence. Why now. 2-4 sentences.>

## Goals

- <Measurable outcome — what changes for the user/system when this ships.>

## Non-goals

- <Explicitly out of scope, with one clause on why, to stop scope creep.>

## Background & constraints

<Current behavior of the affected systems, prior art, and hard constraints
(compatibility, performance budgets, compliance, deadlines) the design must
live within. Written as settled fact.>

## Requirements

Numbered and stable — reference them as FR-1/NFR-1 elsewhere; mark dropped
ones "(dropped)" rather than renumbering.

### Functional

- **FR-1**: <The system MUST/SHOULD... — one observable behavior per line.>

### Non-functional

- **NFR-1**: <Performance / reliability / security / operability bound, with
  a number where one exists.>

## Design

<The selected solution: system boundaries, data model changes, API/interface
shapes, and the general control flow for each significant behavior (as prose
or light pseudo-code). Name real services/modules where known. Stop short of
file-level implementation detail — this reviews the approach, it is not a
task list.>

### Control flow

<For each significant behavior: trigger → steps → outcome. One block per
flow, covering the happy path; unhappy paths live in Edge cases below.>

## Edge cases & failure modes

- <Input/state → expected behavior. The section reviewers skip to first.>

## Acceptance criteria

<How we know it's done: observable checks mapped to requirement numbers,
each verifiable by someone who didn't build it.>

- <FR-1: given X, when Y, then Z.>

## Open questions

- <Unresolved decision, who owns it, and what it blocks. Empty when accepted.>

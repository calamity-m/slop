---
description: Assess the feasibility of a proposed change in an unfamiliar repository and produce a grounded feasibility report
argument-hint: "<proposed-change> [known-leads]"
---

You are being tasked with assessing the feasibility of this proposed change, plus any known leads the user included:

```text
$ARGUMENTS
```

The proposed change may be a feature, refactor, behavior shift, performance improvement, or integration. For example: modifying a frontend table to use async and lazy loading of queries.

The known leads may be files, directories, symbols, components, endpoints, tests, documents, or notes the user already believes are relevant. Start from these leads, or at minimum include them in your initial search before broadening outward.

Your goal is not to implement anything. Your goal is to research the repository enough to judge whether the change is feasible, what it would touch, and what would make it hard. Assume you start with no knowledge of this codebase; prefer verified repository facts over speculation. Where you cannot verify something, say so directly rather than guessing.

Write your final report to:

```text
/tmp/feasibility-report.md
```

Keep the report succinct, concrete, and file-oriented. If the file already exists, overwrite it completely.

Use this structure:

## Verdict

A one-line feasibility call: feasible, feasible-with-caveats, hard, or not-feasible-as-stated. Follow with a 2-3 sentence justification grounded in what you found.

## Current State

How the relevant area works today. Identify the component(s), data flow, and patterns the change would have to fit into or replace. Note whether the prerequisite capabilities (e.g. async data fetching, pagination, state management) already exist or would need to be introduced.

## What the Change Requires

The concrete work the change implies, broken into the distinct pieces it touches. For each piece, name the files or symbols involved and whether existing patterns can be reused.

## Risks and Unknowns

Anything that raises difficulty or uncertainty:

- missing prerequisites
- tight coupling or shared state
- absent or thin test coverage
- external constraints (APIs, libraries, versions)
- ambiguity in the request that changes the scope
- areas you could not verify

## Repository Map

List the files and line ranges a worker agent should inspect first.

Use this format:

```text
Critical Files:
-> path/to/file.ext - Shortest useful description
   -> lines 10-24 - What this block contributes
   -> lines 80-96 - What this block contributes
-> another/path.ext - Shortest useful description
   -> lines 5-12 - What this block contributes
```

Only include files that are actually useful for understanding or making the change. Do not include broad dumps of unrelated search results.

---
description: Recommend which React hook(s) fit a goal, grounded in the patterns this repository already uses
argument-hint: "<what-you-need-to-do> [known-leads]"
---

You are being tasked with recommending the right React hook(s) for this goal:

```text
$1
```

Known starting leads from the user, if any:

```text
${@:2}
```

The goal is something the user needs to accomplish in a component, described in their own terms. For example: "fetch data when a filter changes", "keep a value between renders without re-rendering", "share state across several components", or "debounce an input".

The known leads may be the component this lands in, files, existing hooks, or libraries already in use. Start from these leads, or at minimum include them in your initial search before broadening outward.

Assume the reader is a strong backend engineer who can write the logic but is unsure which React primitive fits, and wants to follow what this codebase already does rather than invent a new pattern. Research the repository first so your recommendation matches the hooks, libraries, and conventions already present. Prefer an existing in-repo pattern over a textbook-correct but foreign one; if you recommend something the repo does not yet use, say so explicitly and justify it. Prefer verified repository facts over speculation; where you cannot verify something, say so directly.

Your goal is not to implement anything. Your goal is to recommend the right hook(s) and show the user the existing pattern to copy.

Write your final report to:

```text
/tmp/react-hook-choice.md
```

Keep the report succinct, concrete, and file-oriented. If the file already exists, overwrite it completely.

Use this structure:

## Recommendation

The hook (or small combination) to use, in one or two lines. Lead with the answer.

## Why This One

Plainly, why this hook fits the goal and what it does for you. If a more obvious-seeming hook is the wrong choice here, say which and why, so the user does not reach for it later.

## What the Repo Already Does

Point to the closest existing usage in this repository — the same hook, a custom hook, or a library helper (e.g. React Query, a shared `use…` hook) that already solves a similar problem. This is the pattern to copy. If nothing comparable exists, state that and note what introducing it implies.

## How to Apply It

A concrete sketch for the user's case: the hook's inputs, its dependency array if relevant, and where the call goes in the component. Flag the one or two things that would break it (missing deps, stale closure, re-render loop) so the user avoids them.

## Repository Map

List the files and line ranges to inspect first.

Use this format:

```text
Critical Files:
-> path/to/file.ext - Shortest useful description
   -> lines 10-24 - What this block contributes
   -> lines 80-96 - What this block contributes
-> another/path.ext - Shortest useful description
   -> lines 5-12 - What this block contributes
```

Only include files that show the pattern to copy or that the change would touch. Do not include broad dumps of unrelated search results.

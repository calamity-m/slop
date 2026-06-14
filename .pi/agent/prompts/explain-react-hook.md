---
description: Explain a React hook and how it is used in this repository, plainly enough to change it safely
argument-hint: "<hook-name-or-usage> [known-leads]"
---

You are being tasked with explaining this React hook:

```text
$1
```

Known starting leads from the user, if any:

```text
${@:2}
```

The target may be a built-in hook (`useState`, `useEffect`, `useMemo`, `useRef`, `useContext`, `useReducer`, etc.), a library hook (e.g. React Query's `useQuery`, Redux's `useSelector`), or a custom hook defined in this repository. It may be named directly or pointed at through a component that uses it.

The known leads may be files, component names, the hook's definition, or notes the user already believes are relevant. Start from these leads, or at minimum include them in your initial search before broadening outward.

Assume the reader is a strong backend engineer who is comfortable with logic but not steeped in React's rendering model. Explain plainly: what the hook does, when it runs, what triggers it to re-run, and what state or side effect it owns. Do not assume familiarity with the render/commit cycle, dependency arrays, or stale-closure pitfalls; state them where they matter. Prefer verified repository facts over speculation; where you cannot verify something, say so directly.

Your goal is not to implement anything. Your goal is to research enough that the user understands this hook and could change its behavior without introducing a re-render bug or stale state.

Write your final report to:

```text
/tmp/react-hook-report.md
```

Keep the report succinct, concrete, and file-oriented. If the file already exists, overwrite it completely.

Use this structure:

## What It Does

A plain-language summary: the hook's job, what value or side effect it manages, and when in the component lifecycle it runs.

## How It Behaves Here

For the actual usage in this repository, trace:

- where the hook is defined (if custom or from a library) and where it is used
- its inputs (arguments, dependency array) and what re-runs it
- the state or side effect it owns, and who reads or depends on that
- any related hooks it coordinates with

## Gotchas

The React-specific traps that apply to this usage, in plain terms:

- dependency-array correctness (missing or extra deps)
- stale closures over props or state
- re-render or effect-loop risks
- cleanup, ordering, or mount/unmount timing

Only list gotchas that genuinely apply to this hook here, with the reason each matters.

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

Only include files that are actually useful for understanding the hook. Do not include broad dumps of unrelated search results.

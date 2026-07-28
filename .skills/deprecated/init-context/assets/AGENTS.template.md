# <project name>

<one-line description of what this project is and who it serves>

## 1. Project Rules

<3-6 rules this repo keeps getting wrong. Each must be specific and enforceable — a rule the agent could not infer from the code and would not abuse as a shortcut. Drop generic posture unless it is unusually important for this repo.>

- <rule — e.g. a pattern that is rejected here, a step that must not be skipped, a tradeoff this repo has already settled>
- <rule>
- <rule>

## 2. Verification

<Concrete checks for this repo. Prefer copy-pasteable commands proven by CI or manifest scripts, and pair each with when to run it.>

- <check — e.g. `cargo test --workspace` — before any commit touching `src/`>
- <check — e.g. `npm run typecheck` — after changing shared types>
- <check — e.g. how to validate a config or generated file that tests do not cover>

## 3. In-Code Documentation

<Only what is project-specific: doc conventions that refine or deviate from the language default, and the repo's real invariants that earn a `why` comment — the things that bite when changed blind. Generic commenting advice ("comment the why", "keep comments short") belongs in user-level context, not here. Split by language in a multi-language repo. Delete this section if the repo has no conventions worth stating.>

- <convention — e.g. "docstrings follow Google style" or "no JSDoc type annotations; TypeScript carries the types">
- <invariant worth a `why` comment — e.g. event ordering, async cancellation, a lock hierarchy>

## 4. Key Decisions

<The handful of architectural facts that change how an agent works here — the things you'd want to know before touching the code, that a quick search would not reveal. Name real types, modules, and entry points. Skip anything an agent would discover anyway.>

- <decision — e.g. the runtime/concurrency model and the libraries it rests on>
- <decision — e.g. the central control-flow construct and why its ordering matters>
- <decision — e.g. a core invariant a key type enforces>

## 5. Local Notes

<Optional: commands, environment assumptions, release quirks, or generated-file rules that are specific to this repo. Delete this section if it would be empty.>

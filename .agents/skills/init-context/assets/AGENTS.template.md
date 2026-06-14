# <project name>

<one-line description of what this project is and who it serves>

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them instead of picking silently.
- If a simpler approach exists, say so. Push back when warranted.
- Don't silently expand into wiring, integrations, or adjacent work that wasn't requested.
- If something is unclear, stop, name what's confusing, and ask.

## 2. Guidelines

<3-6 rules this repo keeps getting wrong. Each must be specific and enforceable — a rule the agent could not infer from the code and would not abuse as a shortcut. Drop generic posture ("write clean code", "make minimal changes"); name the concrete thing this codebase cares about.>

- <rule — e.g. a pattern that is rejected here, a step that must not be skipped, a tradeoff this repo has already settled>
- <rule>
- <rule>

## 3. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let you loop independently. Weak criteria require clarification.

## 4. In-Code Documentation

**Public API must be documented. Internal logic should explain the why.**

<Name the actual language's doc format and the repo's real invariants worth a comment. Drop formats the repo doesn't use.>

For public <language> items:

- Use the language's doc-comment format (<the actual one — rustdoc, docstrings, JSDoc, etc.>).
- Describe what the item is for and any non-obvious parameter, return, or concurrency constraint.
- If the types make everything clear, a one-liner is enough.

For internal code, comment the why, not the what:

- <Name the repo's real invariants that earn a short comment — the things that bite when changed blind.>
- Keep comments short. Delete comments that merely restate the code.

## 5. Key Decisions

<The handful of architectural facts that change how an agent works here — the things you'd want to know before touching the code, that a quick search would not reveal. Name real types, modules, and entry points. Skip anything an agent would discover anyway.>

- <decision — e.g. the runtime/concurrency model and the libraries it rests on>
- <decision — e.g. the central control-flow construct and why its ordering matters>
- <decision — e.g. a core invariant a key type enforces>

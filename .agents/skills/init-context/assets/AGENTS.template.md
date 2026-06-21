# <project name>

<one-line description of what this project is and who it serves>

## 1. Project Rules

<3-6 rules this repo keeps getting wrong. Each must be specific and enforceable — a rule the agent could not infer from the code and would not abuse as a shortcut. Drop generic posture unless it is unusually important for this repo.>

- <rule — e.g. a pattern that is rejected here, a step that must not be skipped, a tradeoff this repo has already settled>
- <rule>
- <rule>

## 2. Verification

<Concrete checks for this repo. Prefer copy-pasteable commands and name when to use each.>

For multi-step tasks, use a brief plan with checks:

```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let agents loop independently. Weak criteria require clarification.

## 3. In-Code Documentation

<Name the actual language's doc format and the repo's real invariants worth a comment. Drop formats the repo doesn't use.>

For public <language> items:

- Use the language's doc-comment format (<the actual one — rustdoc, docstrings, JSDoc, etc.>).
- Describe what the item is for and any non-obvious parameter, return, environment, filesystem, or concurrency constraint.
- If the types and names make everything clear, a one-liner is enough.

For internal code, comment the why, not the what:

- <Name the repo's real invariants that earn a short comment — the things that bite when changed blind.>
- Keep comments short. Delete comments that merely restate the code.

## 4. Key Decisions

<The handful of architectural facts that change how an agent works here — the things you'd want to know before touching the code, that a quick search would not reveal. Name real types, modules, and entry points. Skip anything an agent would discover anyway.>

- <decision — e.g. the runtime/concurrency model and the libraries it rests on>
- <decision — e.g. the central control-flow construct and why its ordering matters>
- <decision — e.g. a core invariant a key type enforces>

## 5. Local Notes

<Optional: commands, environment assumptions, release quirks, or generated-file rules that are specific to this repo. Delete this section if it would be empty.>

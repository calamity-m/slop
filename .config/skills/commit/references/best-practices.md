# Commit Best Practices

Use this file when deciding how to split a change or how to name a commit.

## Pick the Smallest Real Change

- One commit should capture one idea.
- Decide whether the current staged and unstaged changes should become one commit or multiple commits before committing anything.
- If part of the diff could be reverted independently, it probably deserves its own commit.
- Do not bundle cleanup, refactors, and feature work together unless they are inseparable.
- Prefer more small coherent commits over one giant commit.

## Choose a Good Type

- Use `feat` for new capabilities.
- Use `fix` for broken behavior.
- Use `refactor` when the structure changes but the intended behavior does not.
- Use `docs` for documentation-only changes.
- Use `test` for test-only changes.
- Use `chore` for maintenance work that is not a feature or fix.

## Choose a Tight Scope

- The scope should tell the reader where the change lives.
- Good scopes are usually module, feature, skill, or repo areas such as `edit-helm-chart`, `commit`, `agents`, or `repo`.
- Do not use a huge vague scope like `everything`.
- If the change really touches many areas and no tighter scope is honest, use `general`.

## Keep the Subject Short

- Use the format `<type>(scope): short`.
- Make the last part a compact description, not a sentence.
- Good: `feat(commit): add message validator`
- Good: `docs(edit-helm-chart): require render diffs`
- Bad: `updated lots of stuff`

## Keep the Body Short

- Add a body only when it helps.
- Use the body for why, notable constraints, or important side effects.
- Keep it short enough that someone scanning `git log` does not get buried.

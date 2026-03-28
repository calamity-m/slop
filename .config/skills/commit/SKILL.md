---
name: commit
description: "Review local git changes, group them into the smallest coherent commit, and write a conventional-style commit message in the format type(scope): short with a required short body. Use this skill when the user asks to commit changes, wants help choosing a commit message, wants cleaner commit structure, or asks to stage only the relevant files before committing."
---

# Commit

Create small, coherent git commits with a short conventional-style message.

Use the exact subject format:

```text
<type>(scope): short
```

Always include a short body that explains why the change exists.

## Workflow

1. Inspect `git status` and `git diff`.
2. Decide whether the staged and unstaged changes should become one commit or multiple commits.
3. Identify the smallest logical unit of change.
4. Stage only the files that belong in that unit.
5. Write a subject in the required format.
6. Validate the message using the skill's own `scripts/validate-message.sh` — this script lives in the skill directory, not in the repository being committed. Run it as: `<skill-dir>/scripts/validate-message.sh "<subject>" "<body>"`.
7. Commit only after the message and staged file set both make sense.

If unrelated changes are mixed together, split them into separate commits instead of hiding them behind a vague message.

## Message Rules

- Require a subject of the form `<type>(scope): short`.
- Keep the subject short and specific.
- Keep the scope narrow and meaningful: `edit-helm-chart`, `mermaid-sequence-diagram`, `agents`, `repo`.
- If the change genuinely spans the repo and no narrower scope fits, use `general` as the scope.
- Use lowercase for `type` and `scope`.
- Prefer an imperative short description such as `add validator`, `enforce render diffs`, or `document quoting rules`.
- Always include a body explaining why the change was made.
- For multi-concern commits, use the body to explain each distinct change.
- Keep the body direct and focused on why or notable behavior.

## Preferred Types

- `feat`: add user-facing functionality or a new capability
- `fix`: fix a bug or broken behavior
- `refactor`: improve structure without changing intended behavior
- `docs`: documentation-only changes
- `test`: add or adjust tests
- `chore`: maintenance or repo housekeeping

## Staging Rules

- Decide whether one or more commits should be created based on both staged and unstaged files, not just whatever happens to be staged already.
- **Never use partial staging (`git add -p` / `git add --patch`).** Always stage whole files. Do not split a single file across multiple commits.
- If separate files contain unrelated changes, split them into separate commits.
- If unrelated changes live in the same file, commit them together and use the body to describe each concern.
- Do not stage generated output unless the repo clearly tracks it.
- Prefer smaller focused commits when files can be cleanly separated. When they cannot, use a larger commit with a detailed body explaining the included changes.

## Reporting Back

- Tell the user what was committed.
- If the commit body exists, summarize it instead of repeating it verbatim unless asked.
- If there are leftover unstaged or uncommitted changes, say so clearly.

For naming examples and commit-splitting guidance, read [references/best-practices.md](./references/best-practices.md).

## Resources

### scripts/

- `scripts/validate-message.sh`: check that the commit subject matches `<type>(scope): short` and that the required body stays short. **This script is part of the skill directory, not the target repository** — always resolve its path relative to where this skill is installed, never relative to the repo being committed.

### references/

- `references/best-practices.md`: practical guidance for choosing `type`, selecting `scope`, and deciding when to split commits.

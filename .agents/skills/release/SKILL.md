---
name: release
description: "Bump version, run tests, commit with conventional message, and push. Use when the user asks to cut a release, bump a version, or publish."
---

# Release

Bump the project version, verify the build, commit, and push. Always confirm the bump type before touching any file.

## Core Rules

- **Never assume the bump type.** Ask for patch, minor, or major before doing anything.
- Detect the versioning mechanism from the repo (e.g. `package.json`, `Cargo.toml`, `pyproject.toml`, `VERSION` file, `pom.xml`) — do not guess or hardcode a path.
- Run the project's test suite before staging. Abort if it fails; report what failed.
- Commit only the version file(s) and any auto-updated lock files. Do not stage unrelated changes.
- Use a `chore(release): vX.Y.Z` commit subject. No body unless the user adds context.
- Push only after the commit succeeds.

## Workflow

1. **Confirm intent** — ask: patch, minor, or major? If the user already said, confirm by repeating it back before continuing.
2. **Detect versioning** — locate the version file(s). Report what you found and the current version before changing anything.
3. **Bump** — apply the increment to all version files consistently. Show the before/after diff.
4. **Run tests** — execute the project's standard test command. Abort on failure. Report pass/fail.
5. **Stage and commit** — stage only version file(s) and lock files. Commit with `chore(release): vX.Y.Z`.
6. **Push** — push the commit to origin. Report the result and the new version.
7. **Tag** — check whether the repo uses manual git tags (look for existing version tags via `git tag --list` matching `v*` or `*.*.*`). If tags are present, create an annotated tag for the new version (`git tag -a vX.Y.Z -m "release vX.Y.Z"`) and push it with `git push --tags`. If no prior tags exist, ask the user whether to tag before creating one.

## Bump Type Reference

| Type  | When to use                                      |
|-------|--------------------------------------------------|
| patch | Bug fixes, docs, chore; no behavior change       |
| minor | New backwards-compatible features                |
| major | Breaking changes or significant new capabilities |

## Reporting Back

- State the new version and commit hash.
- List the files changed.
- Note whether a tag was created and pushed.
- If anything was skipped (no tests found, lock file absent, no existing tags), say so explicitly.

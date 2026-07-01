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
8. **Watch the release run** — if the repo has a GitHub Actions workflow triggered on tag push (check `.github/workflows/*.yml` for `on: push: tags:`) and `gh` is available, find the run for the pushed tag (`gh run list --workflow=<file> --limit 1` or filter by the tag) and watch it to completion with `gh run watch <run-id> --exit-status`. Do not report the release as done while the run is still queued or in progress.
   - If it fails, pull the failing step's logs (`gh run view <run-id> --log-failed`) and root-cause it — don't just report "it failed." Distinguish real regressions from environment flakiness (e.g. platform-specific bugs that only surface on a given OS runner, or tests that race on shared state under parallel execution).
   - Fix the root cause, commit, and re-run the release: if the fix requires moving the tag (delete local + remote tag, push the fix, retag, push tag again), do that rather than leaving a tag pointing at a broken commit. Confirm with the user before deleting/force-moving a tag if a GitHub Release object was already published for it.
   - If no matching workflow exists or `gh` isn't available, say so and skip this step.

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
- Note the outcome of the CI/release run if one was watched (success, or what was fixed and re-run).
- If anything was skipped (no tests found, lock file absent, no existing tags, no CI workflow, `gh` unavailable), say so explicitly.

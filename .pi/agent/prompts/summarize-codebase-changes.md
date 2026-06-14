---
description: Summarize the direction and substance of recent changes in a repository using git history plus GitHub/GitLab merge request analysis
argument-hint: "<scope-or-range> [known-leads]"
---

You are being tasked with summarizing the changes happening in this repository for:

```text
$1
```

Known starting leads from the user, if any:

```text
${@:2}
```

The scope may be a commit range (e.g. `main..feature-x`, `HEAD~20..HEAD`), a tag span, a date window, a branch, a single merge/pull request, an author, a subsystem, or a general request like "what changed this month". If the scope is ambiguous, state the interpretation you chose before reporting.

The known leads may be branches, MR/PR numbers or URLs, files, directories, subsystems, authors, milestones, or notes the user already believes are relevant. Start from these leads, or at minimum include them before broadening outward.

Your goal is not to implement anything. Your goal is to research the recent change history and distill what is actually changing, why, and where it is heading. Prefer verified facts from git and the forge over speculation. Where you cannot verify intent, say so rather than guessing.

## Gather the Evidence

Do not rely on `git log` alone. Commit messages describe what was committed; merge/pull requests describe intent, discussion, and review. Use both.

Detect the forge before choosing a CLI. Inspect the remote (e.g. `git remote -v`) and pick the matching tool:

- GitHub -> `gh`
- GitLab -> `glab`

Git, for the raw change set:

- `git log --oneline --stat <range>` — what changed and how broadly
- `git log --format='%h %an %ad %s' <range>` — authorship and cadence
- `git diff --stat <range>` and targeted `git diff <range> -- <path>` — the actual code direction
- `git shortlog -sn <range>` — who is driving the changes

GitHub (`gh`), for intent and review context:

- `gh pr list --state merged --search <query>` / `--base <branch>` — merged PRs in scope
- `gh pr view <number> --json title,body,author,mergedAt,labels,files,comments,reviews`
- `gh pr diff <number>` — the change as reviewed

GitLab (`glab`), for the equivalent:

- `glab mr list --merged` (filter by branch, author, label, or milestone as needed)
- `glab mr view <number> --comments`
- `glab mr diff <number>`

If a CLI is unauthenticated or unavailable, say so and fall back to git-only evidence rather than inventing MR/PR details. Note the gap in the report.

Write your final report to:

```text
/tmp/codebase-changes-summary.md
```

Keep the report succinct, concrete, and grounded in commits and MR/PR numbers. If the file already exists, overwrite it completely.

Use this structure:

## Summary

A 100-foot overview of what is changing in this scope: the dominant theme, the volume and cadence of change, and who is driving it. State the scope you actually analyzed (range, branch, dates, MRs/PRs).

## Direction

Where the code is heading, inferred from the change set as a whole. Cover things like:

- new capabilities or features being built out
- refactors, migrations, or architectural shifts in progress
- areas being deprecated, removed, or wound down
- dependency, tooling, or infrastructure movement
- shifts in test, CI, or release practice

Tie each claim to evidence (commit hashes, MR/PR numbers, or file paths).

## Notable Changes

The individual changes that matter most, each anchored to its merge/pull request where one exists. For each:

- one-line description of the change and its intent
- the MR/PR number and merge state, plus key review or discussion outcomes
- the primary files or subsystems touched

Distinguish landed work from in-flight or draft work. Surface any reverts, hotfixes, or contested reviews.

## Signals and Gaps

Anything that colors the interpretation:

- commit-message vs. MR/PR-intent mismatches
- large or unexplained diffs
- changes with no MR/PR (direct pushes)
- evidence you could not gather (auth, missing remote, CLI unavailable)
- ambiguity in the requested scope

## Change Map

List the files and subsystems seeing the most movement, so a reader knows where to look next.

Use this format:

```text
Hotspots:
-> path/to/area.ext - Shortest useful description of what is changing here
   -> MR/PR #123 - What it did
   -> commit abc1234 - What it did
-> another/subsystem/ - Shortest useful description
   -> MR/PR #130 - What it did
```

Only include areas with meaningful change in scope. Do not dump unrelated history.

---
name: Git revert snippets
tags:
  - git
  - revert
  - hotfix
variables:
  remote:
    command: git remote
  branch:
    default: hotfix/revert
  commit:
    command: git log --format=%h --max-count=30
---

# Git Revert Snippets

Safe undo commands for shared branches such as `main`, `production`, or `qa` where history should not be rewritten.

`git revert` creates a new commit containing the inverse delta of an existing commit. Think: cherry-pick, but backwards.

## Revert one commit on current branch

Create a new commit that undoes one earlier commit. This is the usual safe choice for shared branches.

```bash
git revert <@commit>
```

## Revert one commit but inspect first

Apply the inverse delta to your working tree without committing immediately. Useful when you want to review, edit, or test before recording the revert.

```bash
git revert --no-commit <@commit>

git diff
git status
```

## Commit a staged revert

Use after `git revert --no-commit` once the diff looks right and tests have passed.

```bash
git commit -m "Revert <@commit>"
```

## Create a hotfix revert branch from main

Start a branch for a revert PR/MR. This keeps the revert reviewable before it lands back on `main`.

```bash
git switch main
git pull --ff-only <@remote> main
git switch -c <@branch>
```

## Revert on a hotfix branch and push

Create the revert commit on the hotfix branch, then push it so you can open a PR/MR back to `main`.

```bash
git revert <@commit>
git push -u <@remote> HEAD
```

## Revert several specific commits as one commit

Apply multiple inverse deltas without committing each one separately, then make one combined revert commit.

```bash
git revert --no-commit <@commit1:git log --format=%h --max-count=30> <@commit2:git log --format=%h --max-count=30> <@commit3:git log --format=%h --max-count=30>

git diff
git commit -m "Revert problematic changes"
```

## Revert a commit range as one commit

Revert a contiguous range without committing each revert separately.

Note: `old..new` means commits after `old` up to and including `new`; it does not include `old`.

```bash
git revert --no-commit <@old_commit:git log --format=%h --max-count=30>..<@new_commit:git log --format=%h --max-count=30>

git diff
git commit -m "Revert problematic changes"
```

## Revert a merge commit

Undo a merge commit while keeping the first parent, usually the branch you merged into. Be careful: reverting merges can affect future attempts to merge the same branch again.

```bash
git revert -m 1 <@merge_commit:git log --merges --format=%h --max-count=30>
```

## Abort an in-progress revert

Use if a revert produced conflicts or a working-tree state you do not want to keep.

```bash
git revert --abort
```

## Continue a conflicted revert

Use after resolving conflicts from `git revert`.

```bash
git status
git add <@resolved_file:git diff --name-only --diff-filter=U>
git revert --continue
```

## Do not use reset for shared branch undo

Reminder command that intentionally does nothing except document the unsafe alternative. `reset --hard` plus force-push rewrites shared history; prefer `git revert` for `main`, `production`, or `qa`.

```bash
printf '%s\n' 'Avoid: git reset --hard <old-sha> && git push --force'
printf '%s\n' 'Use:   git revert <commit-sha>'
```

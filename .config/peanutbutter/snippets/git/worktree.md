---
name: Git worktree snippets
tags:
  - git
  - worktree
variables:
  worktree:
    command: git worktree list --porcelain | awk '/^worktree / { sub(/^worktree /, ""); print }'
---

# Git Worktree Snippets

Helpers for common git worktree creation and maintenance tasks.

## List worktrees

Show all worktrees, including branch, commit, lock, prune, and bare status.

```sh
git worktree list --verbose
```

## Change directory to worktree

Change into a selected worktree path.

```sh
cd "<@worktree>"
```

## Create worktree for new branch

Create a new branch and check it out in a new worktree.

```sh
git worktree add -b "<@branch>" "<@path:?../repo-worktree>" "<@start:git branch --format='%(refname:short)' --sort=-committerdate>"
```

## Create worktree for existing branch

Check out an existing local branch in a new worktree.

```sh
git worktree add "<@path:?../repo-worktree>" "<@branch:git branch --format='%(refname:short)' --sort=-committerdate>"
```

## Create detached worktree at ref

Create a detached worktree for inspection at a branch, tag, or commit.

```sh
git worktree add --detach "<@path:?../repo-detached>" "<@ref:git for-each-ref --format='%(refname:short)' --sort=-committerdate refs/heads refs/remotes refs/tags | grep -v '/HEAD$'>"
```

## Remove worktree

Remove a worktree path managed by this repository.

```sh
git worktree remove "<@worktree>"
```

## Force remove worktree

Force remove a dirty or broken worktree path managed by this repository.

```sh
git worktree remove --force "<@worktree>"
```

## Prune stale worktree metadata

Remove stale administrative files for deleted or missing worktrees.

```sh
git worktree prune --verbose
```

## Repair worktree metadata

Repair worktree administrative files after paths were moved manually.

```sh
git worktree repair
```

## Lock worktree

Prevent a removable worktree from being pruned.

```sh
git worktree lock "<@worktree>" --reason "<@reason:?in use>"
```

## Unlock worktree

Allow a previously locked worktree to be pruned or removed.

```sh
git worktree unlock "<@worktree>"
```

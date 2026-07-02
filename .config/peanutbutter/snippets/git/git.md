---
tags:
  - git
  - development
variables:
  remote:
    command: git remote
  type:
    suggestions:
      - feat
      - test
      - fix
      - docs
      - chore
      - refactor
      - build
  pattern:
    suggestions:
      - "*.psd"
      - "*.png"
      - "*.pdf"
      - "*.jpg"
      - "*.gif"
---

# Git Snippets

## git commit conventional style

```bash
git commit -m '<@type>(<@scope>): <@message>\n<@body>"
```

## git commit multi-line with EOF

```bash
git commit -m "$(cat <<'EOF'
<@type>(<@scope>): <@message>

<@body>
EOF
)"
```

## git log one line

Compact view of commit history — just the hash and subject. Good for a quick overview of what's been done.

```bash
git log --oneline
```

## git pull main without switching

Fetches `main` from the remote into the local `main` branch while staying on your current branch.

```bash
git fetch <@remote> main:main
```

## git log with bodies

Like `--oneline` but also shows the commit body. Useful when you care about the detail in commit messages, not just the subject.

```bash
git log --format="%C(yellow)%h%Creset %s%n%b"
```

## git amend latest commit title

```bash
git commit --amend -m "<@message>"
```

## git reflog

Shows every place HEAD has pointed — including commits that no longer appear in `git log` (e.g. after a reset, rebase, or dropped stash). Use this to recover "lost" commits by finding their hash and checking out or cherry-picking them.

```bash
git reflog
```

## git enable lfs

```bash
git lfs install
```

## git track file type with lfs

```bash
git lfs track "<@pattern>"
git add .gitattributes
```

## git delete local branches not on remote

```bash
git fetch --prune
git branch -vv | awk '/: gone]/{print $1 == "*" ? $2 : $1}' | xargs -r git branch -D
```

## git delete local branches except main or master

```bash
git switch main || git switch master
git branch --format='%(refname:short)' | grep -Ev '^(main|master)$' | xargs -r git branch -D
```

## git rebase onto branch's own first commit

Interactive rebase starting only from where this branch diverged from `<@base:?main>`, instead of onto `<@base:?main>`'s current tip. Lets you squash and reword your branch's commits without pulling in upstream changes that would cause conflicts.

```bash
git rebase -i "$(git merge-base <@base:?main> HEAD)"
```

## git delete branch on remote and local

```bash
branch="<@branch:git branch --format='%(refname:short)'>"

git push "<@remote>" --delete "$branch"
git branch -D "$branch"
```

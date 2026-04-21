---
tags:
    - git
    - development
---


# Git Snippets

## git commit convential style

```
git commit -m '<@type:echo "feat\ntest\nfix">(<@scope>): <@message>\n<@body>"
```

## git commit multi-line with EOF

```
git commit -m "$(cat <<'EOF'
<@type:echo "feat\nfix\nchore\ndocs\nrefactor\ntest\nperf\nci\nbuild\nstyle">(<@scope>): <@message>

<@body>
EOF
)"
```

## git log one line

Compact view of commit history — just the hash and subject. Good for a quick overview of what's been done.

```
git log --oneline
```

## git log with bodies

Like `--oneline` but also shows the commit body. Useful when you care about the detail in commit messages, not just the subject.

```
git log --format="%C(yellow)%h%Creset %s%n%b"
```

## git amend latest commit title

```
git commit --amend -m "<@message>"
```

## git reflog

Shows every place HEAD has pointed — including commits that no longer appear in `git log` (e.g. after a reset, rebase, or dropped stash). Use this to recover "lost" commits by finding their hash and checking out or cherry-picking them.

```
git reflog
```


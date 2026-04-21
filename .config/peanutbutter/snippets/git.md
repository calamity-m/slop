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

```
git log --oneline
```

## git log with bodies

```
git log --format="%C(yellow)%h%Creset %s%n%b"
```

## git amend latest commit title

```
git commit --amend -m "<@message>"
```


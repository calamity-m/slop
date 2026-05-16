---
name: Helpers
---

# Helper Snippets

General snippets that can be used to extend terminal commands

## Pipe stdout and stderr to file and terminal

```bash
<@command> 2>&1 | tee <@file>
```

## Pipe stdout to clipboard with xclip

```bash
<@command> | xclip -selection clipboard
```

## Write multiline content to file with heredoc

```bash
cat <<'EOF' > <@file>
<@content>
EOF
```

## Run command without saving to history

```bash
<@command>; history -d $(history 1)
```

## If/else one liner

```bash
if [[ <@condition> ]]; then <@then>; else <@else>; fi
```

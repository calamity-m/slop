---
name: Helpers
---

# Helper Snippets

General snippets that can be used to extend terminal commands

## Pipe stdout and stderr to file and terminal

```
<@command> 2>&1 | tee <@file>
```

## Pipe stdout to clipboard with xclip

```
<@command> | xclip -selection clipboard
```

## Write multiline content to file with heredoc

```
cat <<'EOF' > <@file>
<@content>
EOF
```

## Run command without saving to history

```
<@command>; history -d $(history 1)
```

## If/else one liner

```
if [[ <@condition> ]]; then <@then>; else <@else>; fi
```

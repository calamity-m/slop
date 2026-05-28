---
name: IO
---

# IO Snippets

Snippets for redirecting and moving data around

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

## Suppress stderr

```bash
<@command> 2>/dev/null
```

## Discard all output

```bash
<@command> &>/dev/null
```

## Pipe stdout into nvim

```bash
<@command> | nvim -
```

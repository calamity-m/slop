---
name: IO
---

# IO Snippets

Snippets for redirecting and moving data around

## Run command with output sent to file

```bash
<@command> > <@file>
```

## Redirect stderr to stdout

`2>&1` sends stderr (file descriptor 2) to the same destination as stdout (file descriptor 1).

```bash
<@command> 2>&1
```

## Pipe stdout and stderr to file and terminal

```bash
<@command> 2>&1 | tee <@file>
```

## Pipe stdout to clipboard with xclip

```bash
<@command> | xclip -selection clipboard
```

## Copy revdiff annotations to clipboard

Runs the interactive review and copies saved annotations after exit. Use `q` to keep annotations; `Q` discards them.

```bash
revdiff-clip <@args>
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

---
tags:
  - rg
  - grep
  - files
  - directories
---

# Ripgrep

## find files with extension(s)

```bash
rg --files -g "*.{<@extension>,<@extension_two>}"
```

## List files in a directory that match a pattern

```bash
rg --files <@directory> | rg <@pattern>
```

## List files in a directory that do not match a pattern

```bash
rg --files <@directory> | rg -v <@pattern>
```

## List filenames whose contents match a pattern

Searches file contents from the current directory down and prints only the
matching file paths, one per line.

- `-i` makes the match case insensitive
- `--files-without-match` performs the inverse

```bash
rg -l <@pattern>
```

## List filenames whose contents match a pattern, limited to a file type

`rg --type-list` shows the available type names.

```bash
rg -l -t <@type:rg --type-list | cut -d: -f1> <@pattern>
```

## List filenames whose contents match a pattern, limited to a glob

The glob and the pattern match different things:

- `<@glob>` is shell-style wildcards matched against the file path, and decides
  which files get searched at all. `.` is a literal dot; prefix with `!` to
  exclude, as in `!**/vendor/**`
- `<@pattern>` is a regex matched against the contents of those files

So `-g "*.go" "func main"` means "of the `.go` files, which contain `func main`".

```bash
rg -l -g "<@glob>" <@pattern>
```

## Count matches per file

Prints `path:count` for each file containing the pattern, skipping files with
zero matches.

```bash
rg -c <@pattern>
```

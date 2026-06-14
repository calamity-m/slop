---
tags:
  - fd
  - find
  - files
  - directories
variables:
  pattern:
    default: .
  directory:
    default: .
  extension:
    suggestions:
      - md
      - json
      - xml
      - java
      - go
      - rust
      - py
      - yaml
      - toml
      - csv
      - txt
---

# fd Snippets

`fd` is a fast, user-friendly alternative to `find`. It respects `.gitignore` by
default and uses regex patterns unless `--glob` is passed.

## fd find by name pattern in a directory

```bash
fd <@pattern> <@directory>
```

## fd find files with extension(s)

`-e` matches a single extension; repeat the flag for more.

```bash
fd -e <@extension> <@pattern> <@directory>
```

## fd find only directories

```bash
fd --type directory <@pattern> <@directory>
```

## fd find including hidden and ignored files

`-H` includes hidden files, `-I` ignores `.gitignore` rules. Useful when hunting
for files `fd` would normally skip.

```bash
fd -HI <@pattern> <@directory>
```

## fd execute a command per match

`-x` runs the command once per result in parallel; `{}` expands to each path.

```bash
fd -e <@extension> -x <@command> {}
```

## fd execute a command once with all matches

`-X` batches every result into a single command invocation (like `xargs`).

```bash
fd -e <@extension> -X <@command>
```

## fd find and delete matches

`-x` runs `rm` per match. Run without `-x` first to preview what will be deleted.

```bash
fd <@pattern> <@directory> -x rm
```

## fd find recently changed files

`--changed-within` accepts durations like `2h`, `1d`, or `1week`.

```bash
fd --changed-within <@duration> <@pattern> <@directory>
```

## fd find by glob instead of regex

```bash
fd --glob '<@glob>' <@directory>
```

## fd find matches and copy them into one flat directory

Collects every match into a single destination, ignoring their original nesting:
`cp {} <dest>/` keeps each file's basename, so `src/a/file.txt` lands at
`<dest>/file.txt`. `mkdir -p` ensures the destination exists; the trailing slash
forces `cp` to treat it as a directory (and fails safely if it is a file).

Caveat: flattening means matches that share a basename collide, and the later
`cp` overwrites the earlier one. If you expect collisions, swap `cp` for
`cp -n` (no-clobber) or `cp --backup=numbered`.

```bash
mkdir -p <@destination> && fd <@pattern> <@directory> -x cp {} <@destination>/
```

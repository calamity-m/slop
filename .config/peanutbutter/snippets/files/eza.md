---
variables:
  sort:
    suggestions:
      - name
      - size
      - extension
      - changed
      - modified
      - accessed
      - created
      - ninode
      - type
      - none
  path:
    default: .
  directory:
    default: .
---

# Eza Snippets

## eza long list, hidden files, sorted

```bash
eza -lha -s <@sort>
```

## eza long list with hidden files and block sizes

Equivalent to the `ls -lsha` habit: `-l` uses long listing, `-a` includes hidden files, and `-S` adds the allocated block-size column. `--header` labels the columns and `--icons` keeps the output consistent with the shell aliases.

```bash
eza -laS --header --icons auto <@path>
```

## eza list files and directories with total sizes

`--total-size` calculates and displays the full size of each directory instead of only its directory-entry size.

```bash
eza -lah --total-size <@path>
```

## eza list directories in a directory

Example:

```text
.hidden-dir
hello-world
hi-there
```

```bash
eza --oneline --only-dirs --all --git-ignore --ignore-glob .git <@directory>
```

## eza list files and directories in a tree format

- the `--icons` just displays nice icons
- add `--group-directories-first` to display directories ahead of plain files
- the `--tree` is what gives the nice tree output
- `-git-ignore` is pretty self explanatory

Example:

```text
 .
├──  .agents
│   └──  skills
│       ├──  bigplan
│       │   ├──  references
│       │   │   └──  adversarial-reviewer.md
│       │   └──  SKILL.md
│       ├──  code-review
│       │   ├──  agents
│       │   │   └──  openai.yaml
```

```bash
eza --tree --git-ignore --all --icons auto <@directory>
```

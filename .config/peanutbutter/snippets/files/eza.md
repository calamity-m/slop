---
tags:
  - eza
  - tool
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

## kitchen sink

```bash
eza -laSmgh@ --git --classify auto --total-size <@path>
```

## sort files

Sorts with the highest match at the bottom. To reverse, run with `-r`

```bash
eza --long --total-size --accessed --modified --created --header --sort <@sort> <@path>
```

## sort directories by total size

Sorts just directories, with the highest match at the bottom. To reverse, run with `-r`.
To include files, you can omit the `--only-dirs`, or for inversion - `--only-files`

```bash
eza -la --only-dirs --total-size --sort size
```

## display column headers

the `-h` flag will provide header columns.

```bash
eza -lh
```

## list directories in a directory

```bash
eza --oneline --only-dirs --all --git-ignore --ignore-glob .git <@directory>
```

## tree with eza

- the `--icons` just displays nice icons
- add `--group-directories-first` to display directories ahead of plain files
- the `--tree` is what gives the nice tree output
- the `--level` is what defines the depth
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
eza --tree --git-ignore --all --icons auto --level 100 <@directory>
```

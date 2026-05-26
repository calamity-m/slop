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

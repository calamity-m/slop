---
tags:
  - find
  - files
  - directories
variables:
  path:
    default: .
---

# Find Snippets

## find files and directories with total sizes

Uses `du` to calculate the full size of directories recursively, then sorts the results by size. `-mindepth` and `-maxdepth` are GNU `find` options.

```bash
find <@path> -mindepth 1 -maxdepth 1 -exec du -sh -- {} + | sort -h
```

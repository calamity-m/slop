---
tags:
  - pb
  - general
  - scratch
variables:
  file:
    command: rg . --files
---

# General Snippets

This file holds general top-level widgets, often acting as a scratch-pad for snippets
before they can be curated into a proper area, or removed for being useless/pointless.

## Search file, but return only the matching portion if it exists

```bash
(
# just invert the -o to -v to exclude it
grep -o "<@pattern>" <@file>
)
```

## Find directories with a max depth of 1

```bash
find <@start:?.> -maxdepth 1
```

## list all possible paths of an executable/binary

```bash
which -a <@cmd>
```

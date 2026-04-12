# General Snippets

This file holds general top-level widgets, often acting as a scratch-pad for snippets
before they can be curated into a proper area, or removed for being useless/pointless.


## Grep - but only return only the matching portion

```
(
# just invert the -o to -v to exclude it 
grep -o "<@pattern>" <@file:rg . --files>
)
```

## Find directories with a max depth of 1

```
find <@start:?.> -maxdepth 1
```

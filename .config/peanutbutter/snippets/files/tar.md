---
variables:
  depth:
    suggestions:
      - 1
      - 2
      - 3
  tar:
    command: rg . --files
---

# Tar Snippets

## Create tar

```bash
tar -czvf <@out>.tar.gz <@src:rg . --files>
```

## Create tar from directory using relative paths

```bash
tar czf <@out>.tar.gz -C <@directory> .
```

## List tar contents

List files inside a tar archive without extracting it.

```bash
tar -tf <@tar>
```

## Untar into directory

```bash
tar -xzvf <@tar> -C <@dest>
```

## Untar specific file

```bash
tar -xzvf <@tar> <@file>
```

## Untar, strip prefix

```bash
tar -xzvf <@tar> -C <@dest> --strip-components=<@depth>
```

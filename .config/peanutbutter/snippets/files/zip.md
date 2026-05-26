---
variables:
  zip:
    command: rg . --files
  gz:
    command: rg . --files
---

# Zip Snippets

## Create zip

```bash
zip -r <@out>.zip <@src>
```

## Unzip into directory

```bash
unzip <@zip> -d <@dest>
```

## Unzip specific file

```bash
unzip <@zip> <@file>
```

## List contents of zip

```bash
unzip -l <@zip>
```

## Gzip a file

```bash
gzip <@file>
```

## Gzip, keep original

```bash
gzip -k <@file>
```

## Gunzip a file

```bash
gunzip <@gz>
```

## Gunzip, keep original

```bash
gunzip -k <@gz>
```

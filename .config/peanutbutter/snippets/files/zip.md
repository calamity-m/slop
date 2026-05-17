# Zip Snippets

## Create zip

```bash
zip -r <@out>.zip <@src>
```

## Unzip into directory

```bash
unzip <@zip:rg . --files> -d <@dest>
```

## Unzip specific file

```bash
unzip <@zip:rg . --files> <@file>
```

## List contents of zip

```bash
unzip -l <@zip:rg . --files>
```

## Gzip a file

```bash
gzip <@file:rg . --files>
```

## Gzip, keep original

```bash
gzip -k <@file:rg . --files>
```

## Gunzip a file

```bash
gunzip <@gz:rg . --files>
```

## Gunzip, keep original

```bash
gunzip -k <@gz:rg . --files>
```

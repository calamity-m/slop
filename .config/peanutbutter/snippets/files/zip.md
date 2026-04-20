# Zip Snippets

## Create zip

```
zip -r <@out>.zip <@src>
```

## Unzip into directory

```
unzip <@zip:rg . --files> -d <@dest>
```

## Unzip specific file

```
unzip <@zip:rg . --files> <@file>
```

## List contents of zip

```
unzip -l <@zip:rg . --files>
```

## Gzip a file

```
gzip <@file:rg . --files>
```

## Gzip, keep original

```
gzip -k <@file:rg . --files>
```

## Gunzip a file

```
gunzip <@gz:rg . --files>
```

## Gunzip, keep original

```
gunzip -k <@gz:rg . --files>
```

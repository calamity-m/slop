# Tar Snippets

## Create tar

```
tar -czvf <@out>.tar.gz <@src:rg . --files>
```

## Untar into directory

```
tar -xzvf <@tar:rg . --files> -C <@dest>
```

## Untar specific file

```
tar -xzvf <@tar:rg . --files> <@file>
```

## Untar, strip prefix

```
tar -xzvf <@tar:rg . --files> -C <@dest> --strip-components=<@depth:echo "1\n2\n3">
```

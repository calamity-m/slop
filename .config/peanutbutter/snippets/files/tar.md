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
tar -tf <@tar:rg . --files>
```

## Untar into directory

```bash
tar -xzvf <@tar:rg . --files> -C <@dest>
```

## Untar specific file

```bash
tar -xzvf <@tar:rg . --files> <@file>
```

## Untar, strip prefix

```bash
tar -xzvf <@tar:rg . --files> -C <@dest> --strip-components=<@depth:echo "1\n2\n3">
```

# Tar Snippets

## Create tar

```
tar -czvf <@out>.tar.gz <@src:rg . --files>
```

## Create tar from directory using relative paths

```
tar czf <@out>.tar.gz -C <@directory> .
```

## List tar contents

List files inside a tar archive without extracting it.

```
tar -tf <@tar:rg . --files>
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

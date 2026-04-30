# Eza Snippets

## eza long list, hidden files, sorted

```
eza -lha -s <@sort:echo "name\nName\nsize\nextension\nExtension\nmodified\nchanged\naccessed\ncreated\ninode\ntype\nnone">
```

## eza list directories in a directory

```
eza --oneline --only-dirs --all --git-ignore --ignore-glob .git <@directory>
```

Example:

```text
.hidden-dir
hello-world
hi-there
```

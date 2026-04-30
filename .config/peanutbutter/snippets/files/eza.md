# Eza Snippets

## eza long list, hidden files, sorted

```
eza -lha -s <@sort:echo "name\nName\nsize\nextension\nExtension\nmodified\nchanged\naccessed\ncreated\ninode\ntype\nnone">
```

## eza long list with hidden files and block sizes

Equivalent to the `ls -lsha` habit: `-l` uses long listing, `-a` includes hidden files, and `-S` adds the allocated block-size column. `--header` labels the columns and `--icons` keeps the output consistent with the shell aliases.

```
eza -laS --header --icons <@path:?.>
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

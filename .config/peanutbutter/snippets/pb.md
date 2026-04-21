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

## git commit convential style

```
git commit -m '<@type:echo "feat\ntest\nfix">(<@scope>): <@message>\n<@body>"
```

## git commit multi-line with EOF

```
git commit -m "$(cat <<'EOF'
<@type:echo "feat\nfix\nchore\ndocs\nrefactor\ntest\nperf\nci\nbuild\nstyle">(<@scope>): <@message>

<@body>
EOF
)"
```

## list files and directories in tree format, adhereing to gitignore

- the `--icons` just displays nice icons
- add `--group-directories-first` to display directories ahead of plain files
- the `--tree` is what gives the nice tree output


```
eza --tree --git-ignore --icons
```

---
tags:
    - cli
    - terminal
---

# Tools

## dexec - execute/Run/Pop a hell/bash in a running container

When you run the snippet you'll be presented with a TUI that lets you
select a docker container to get a shell on it.

```
dexec
```

## zellij - spawn project tab

Create a new zellij tab with an nvim project layout setup from the get-go.

``` 
zellij action new-tab --layout ~/.config/zellij/layouts/nvim-project.kdl --cwd <@project:find ~/code -maxdepth 1 | tail -n +2>
```

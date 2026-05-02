---
name: Zellij
tags:
  - cli
  - terminal
---

## spawn/create project tab

Create a new zellij tab with an nvim project layout setup from the get-go.

```
project="<@project:find ~/code -maxdepth 1 | tail -n +2>"; zellij action new-tab --layout ~/.config/zellij/layouts/nvim-project.kdl --cwd "$project" --name "$(basename "$project")"
```

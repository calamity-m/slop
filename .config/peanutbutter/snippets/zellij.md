---
name: Zellij
tags:
  - cli
  - terminal
---

## apply project layout to current tab

Apply the nvim project layout to the current zellij tab.

```
project="<@project:find ~/code -maxdepth 1 | tail -n +2>"; zellij action rename-tab "$(basename "$project")"; cd "$project" && zellij action override-layout ~/.config/zellij/layouts/nvim-project.kdl --apply-only-to-active-tab
```

## apply base layout to current tab

Apply a four-pane base layout to the current zellij tab.

```
zellij action override-layout ~/.config/zellij/layouts/base.kdl --apply-only-to-active-tab
```

## kill current session

Quit the current zellij session.

```
zellij kill-session
```

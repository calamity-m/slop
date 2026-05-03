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
zellij action rename-tab base; zellij action override-layout ~/.config/zellij/layouts/base.kdl --apply-only-to-active-tab
```

## apply agent stack layout to current tab

Apply the agent stack layout to the current zellij tab.

```
project="<@project:find ~/code -maxdepth 1 | tail -n +2>"
tab_name="$(basename "$project")-agents"
zellij action rename-tab "$tab_name"
cd "$project" && zellij action override-layout ~/.config/zellij/layouts/agent-stack.kdl --apply-only-to-active-tab
tab_id="$(zellij action current-tab-info --json | jq -r '.tab_id')"
i=0
zellij action list-panes --json --all --tab --state --geometry \
    | jq -r --argjson tab_id "$tab_id" '[.[] | select(.tab_id == $tab_id and (.is_plugin | not) and (.is_floating | not))] | sort_by(.pane_y, .pane_x, .id) | .[].id' \
    | while IFS= read -r pane_id; do
        i=$((i + 1))
        case "$i" in
            1) pane_name="agent-1" ;;
            2) pane_name="agent-2" ;;
            3) pane_name="nvim" ;;
            *) continue ;;
        esac
        zellij action rename-pane --pane-id "terminal_${pane_id}" "$pane_name"
    done
```

## kill current session

Quit the current zellij session.

```
zellij kill-session "$ZELLIJ_SESSION_NAME"
```

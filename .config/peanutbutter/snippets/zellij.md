---
name: Zellij
tags:
  - cli
  - terminal
  - zellij
variables:
  session_name:
    suggestions:
      - main
      - test
      - scratch
      - work
      - dev
  tab_name:
    suggestions:
      - main
      - test
      - scratch
      - slop
      - dev
      - longlived
  session:
    command: zellij list-sessions --short --no-formatting
---

## apply project layout to current tab

Apply the nvim project layout to the current zellij tab from the current directory.

```bash
project="$PWD"; zellij action rename-tab "$(basename "$project")"; cd "$project" && zellij action override-layout ~/.config/zellij/layouts/nvim-project.kdl --apply-only-to-active-tab
```

## apply base layout to current tab

Apply a four-pane base layout to the current zellij tab.

```bash
zellij action rename-tab base; zellij action override-layout ~/.config/zellij/layouts/base.kdl --apply-only-to-active-tab
```

## apply agent stack layout to current tab

Apply the agent stack layout to the current zellij tab from the current directory.

```bash
project="$PWD"
tab_name="$(basename "$project")-agents"
zellij action rename-tab "$tab_name"
cd "$project" && zellij action override-layout ~/.config/zellij/layouts/agent-stack.kdl --apply-only-to-active-tab
```

## start named sessions

```bash
zellij --session <@session_name>
```

## kill a named session

Killing a session leaves it still usable later

```bash
zellij kill-session <@session>
```

## delete a named session

Delete a session once killed to fully remove it forever

```bash
zellij delete-session <@session>
```

## attach to session

```bash
zellij attach <@session>
```

## rename current session

```bash
zellij action rename-session <@session_name>
```

## rename current tab

```bash
zellij action rename-tab <@tab_name>
```

## rename current tab to cwd

Rename the current zellij tab to the current directory name.

```bash
zellij action rename-tab "$(basename "$PWD")"
```

## detach current session

Detach from the current zellij session without killing it.

```bash
zellij action detach
```

## kill current session

```bash
zellij kill-session "$ZELLIJ_SESSION_NAME"
```

## delete all sessions

```bash
zellij delete-all-sessions
```

## kill all sessions

```bash
zellij kill-all-sessions
```

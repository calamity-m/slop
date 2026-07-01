---
name: Herdr
description: Terminal workspace/session helpers for Herdr
tags:
  - cli
  - terminal
  - herdr
variables:
  session_name:
    suggestions:
      - default
      - main
      - scratch
      - work
      - dev
  session:
    command: herdr session list --json | jq -r '.sessions[]?.name // empty'
  workspace:
    command: herdr workspace list | jq -r '.result.workspaces[]?.workspace_id // empty'
  tab:
    command: herdr tab list | jq -r '.result.tabs[]?.tab_id // empty'
  pane:
    command: herdr pane list | jq -r '.result.panes[]?.pane_id // empty'
  agent:
    command: herdr agent list | jq -r '.result.agents[]?.pane_id // empty'
  sound:
    suggestions:
      - none
      - done
      - request
  workspace_label:
    suggestions:
      - main
      - test
      - scratch
      - slop
      - dev
  tab_label:
    suggestions:
      - main
      - test
      - scratch
      - agents
      - logs
  direction:
    suggestions:
      - right
      - down
      - left
      - up
  split_direction:
    suggestions:
      - right
      - down
  agent_name:
    suggestions:
      - pi
      - claude
      - codex
      - opencode
---

## launch or attach default session

Launch Herdr or attach to the persistent default session.

```bash
herdr
```

## detach reminder

Herdr does not currently expose a CLI detach command; press the configured prefix, then `q`. This config uses `ctrl+g`, so detach is `ctrl+g q`.

```bash
printf 'Detach Herdr: press Ctrl-g, then q\n'
```

## start named session

Launch or attach a named persistent Herdr session.

```bash
herdr --session <@session_name>
```

## attach to named session

Attach to an existing Herdr session by name.

```bash
herdr session attach <@session>
```

## stop named session

Stop a running Herdr session without deleting its saved state.

```bash
herdr session stop <@session>
```

## delete named session

Delete a stopped Herdr session. This is destructive for that saved session.

```bash
herdr session delete <@session>
```

## show status

Show client/server status, compatibility, socket, and update state.

```bash
herdr status
```

## reload config

Reload `~/.config/herdr/config.toml` in the running Herdr server.

```bash
herdr server reload-config
```

## create workspace from cwd

Create and focus a new workspace rooted at the current directory.

```bash
herdr workspace create --cwd "$PWD" --label <@workspace_label> --focus
```

## focus workspace

Focus an existing workspace by id.

```bash
herdr workspace focus <@workspace>
```

## rename workspace

Rename an existing workspace.

```bash
herdr workspace rename <@workspace> <@workspace_label>
```

## close workspace

Close an existing workspace. Herdr may ask for confirmation depending on config.

```bash
herdr workspace close <@workspace>
```

## create tab from cwd

Create and focus a new tab in the current workspace rooted at the current directory.

```bash
herdr tab create --cwd "$PWD" --label <@tab_label> --focus
```

## focus tab

Focus an existing tab by id.

```bash
herdr tab focus <@tab>
```

## rename tab

Rename an existing tab.

```bash
herdr tab rename <@tab> <@tab_label>
```

## close tab

Close an existing tab by id.

```bash
herdr tab close <@tab>
```

## split current pane

Split the current pane right or down and focus the new pane.

```bash
herdr pane split --current --direction <@split_direction> --cwd "$PWD" --focus
```

## focus pane direction

Move focus from the current pane in a direction.

```bash
herdr pane focus --current --direction <@direction>
```

## zoom current pane

Toggle zoom for the current pane.

```bash
herdr pane zoom --current --toggle
```

## rename pane

Rename a pane by id.

```bash
herdr pane rename <@pane> <@pane_label>
```

## read pane recent output

Print recent pane output as plain text.

```bash
herdr pane read <@pane> --source recent --lines <@lines:?80> --format text
```

## send text to pane

Send literal text to a pane without pressing Enter.

```bash
herdr pane send-text <@pane> <@text>
```

## run command in pane

Type a command into a pane and press Enter.

```bash
herdr pane run <@pane> <@command>
```

## start agent in split

Start an agent command in a new split in the current workspace/tab.

```bash
herdr agent start <@agent_name> --cwd "$PWD" --split <@split_direction> --focus -- <@agent_command:?pi>
```

## focus agent

Focus an agent target. Targets accept terminal ids, unique agent names, labels, and pane ids.

```bash
herdr agent focus <@agent>
```

## read agent recent output

Print recent output for an agent target as plain text.

```bash
herdr agent read <@agent> --source recent --lines <@lines:?80> --format text
```

## send message to agent

Send literal text to an agent target without pressing Enter.

```bash
herdr agent send <@agent> <@message>
```

## wait for agent idle

Block until an agent target reports idle, or time out.

```bash
herdr agent wait <@agent> --status idle --timeout <@timeout_ms:?600000>
```

## create git worktree workspace

Create a Herdr-managed Git worktree workspace from the current repository.

```bash
herdr worktree create --cwd "$PWD" --branch <@branch> --base <@base:?HEAD> --label <@workspace_label> --focus
```

## open git worktree workspace

Open an existing Git worktree as a Herdr workspace.

```bash
herdr worktree open --cwd "$PWD" --branch <@branch> --label <@workspace_label> --focus
```

## show notification

Show a Herdr notification.

```bash
herdr notification show <@title> --body <@body> --sound <@sound:?none>
```

## install agent integration

Install a built-in Herdr integration for an agent CLI.

```bash
herdr integration install <@agent_name>
```

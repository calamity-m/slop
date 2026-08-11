---
name: Process
tags:
  - cli
  - terminal
variables:
  port:
    hint: e.g. 8080
  count:
    default: "11"
  pattern:
    hint: e.g. gradle
  pid:
    command: ps -eo pid,comm --sort=comm --no-headers
---

# Process Snippets

Snippets for inspecting and managing running processes and ports

## Find process listening on a port

Show which process (PID, command, user) is bound to a TCP port, e.g. checking what's holding `localhost:8080`.

```bash
lsof -i :<@port>
```

## Kill process listening on a port

Force-kill whatever process is bound to a TCP port. Destructive: sends `SIGKILL` immediately with no confirmation prompt.

```bash
kill -9 $(lsof -t -i:<@port>)
```

## Top CPU processes

Show the processes using the most CPU. `count` includes the header row, so the default of 11 shows the top 10 processes.

```bash
ps aux --sort=-%cpu | head -n <@count>
```

## Top memory processes

Show the processes using the most memory.

```bash
ps aux --sort=-%mem | head -n <@count>
```

## Search running processes by name

Find PIDs and command lines matching a pattern, e.g. `gradle`. Uses `pgrep` instead of `ps aux | grep` so the grep command itself never shows up in the output.

```bash
pgrep -af <@pattern>
```

## Kill processes by name

Force-kill every process whose command line matches a pattern, e.g. `gradle`. Destructive: sends `SIGKILL` immediately with no confirmation prompt, and matches against the full command line, not just the process name.

```bash
pkill -9 -f <@pattern>
```

## Show open files for a process

List files, sockets, and pipes a process currently has open. Useful for tracking down "file is busy"/"address in use" errors beyond just ports. The `pid` suggestions show `PID COMMAND`; only the PID is used.

```bash
lsof -p $(awk '{print $1}' <<< '<@pid>')
```

## Process tree for a PID

Show a process and its descendants, so you can see what spawned what.

```bash
pstree -p $(awk '{print $1}' <<< '<@pid>')
```

## Environment variables of a running process

Dump the environment a running process was started with. Linux-only (reads `/proc`); requires permission to inspect the target process (same user, or root).

```bash
cat /proc/$(awk '{print $1}' <<< '<@pid>')/environ | tr '\0' '\n'
```

## Live-watch top CPU processes

Auto-refreshing view of the busiest processes by CPU.

```bash
watch -n 2 'ps aux --sort=-%cpu | head -n <@count>'
```

## Live-watch top memory processes

Auto-refreshing view of the busiest processes by memory.

```bash
watch -n 2 'ps aux --sort=-%mem | head -n <@count>'
```

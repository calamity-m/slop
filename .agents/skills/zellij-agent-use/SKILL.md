---
name: zellij-agent-use
description: Drive and inspect interactive terminal UI applications through Zellij panes. Use when an agent needs to launch a TUI, send keys or text, capture the pane viewport or scrollback, and iterate without a human acting as the terminal operator.
---

# Zellij Agent Use

Use this skill to test interactive terminal applications through an existing Zellij session. The goal is an observe-act loop:

```text
launch or identify pane -> capture screen -> send input -> capture again -> assert visible state
```

Prefer `scripts/ztui` over raw `zellij action` commands so pane targeting and capture behavior stay consistent.

## Requirements

- `zellij` must be installed.
- Run the agent from inside the Zellij session, or run these commands from a dedicated control pane inside that session.
- If a sandboxed tool runner reports `There is no active session`, rerun the `ztui` command outside the sandbox with user approval. Zellij's action socket can be hidden by sandbox isolation even when the agent process is visibly running in a Zellij pane.
- Use pane IDs such as `terminal_3`. Bare numeric IDs usually work, but stable full IDs are clearer.
- For assertions, use plain `capture` output unless ANSI styling is the thing being tested.

## Workflow

1. Find or create the TUI pane:

```bash
.agents/skills/zellij-agent-use/scripts/ztui panes
.agents/skills/zellij-agent-use/scripts/ztui run --name tui-under-test -- cargo run
```

2. Capture the current viewport:

```bash
.agents/skills/zellij-agent-use/scripts/ztui capture terminal_3
```

3. Send input:

```bash
.agents/skills/zellij-agent-use/scripts/ztui key terminal_3 Tab
.agents/skills/zellij-agent-use/scripts/ztui text terminal_3 "filter text"
.agents/skills/zellij-agent-use/scripts/ztui enter terminal_3
```

4. Wait for an expected screen state when the TUI updates asynchronously:

```bash
.agents/skills/zellij-agent-use/scripts/ztui wait terminal_3 "Expected text" --timeout 5
```

5. Capture again and inspect the visible state. Repeat until the workflow has been exercised.

## Input Notes

- Use `key` for special keys: `Enter`, `Esc`, `Tab`, `Backspace`, `Up`, `Down`, `Left`, `Right`, `Ctrl c`.
- Use `text` for literal typing. It does not press Enter.
- Use `type-enter` for text followed by Enter.
- If input appears to do nothing, capture the pane and check focus or app mode before sending more keys.

## Capture Notes

- `capture <pane>` dumps the visible viewport.
- `capture --full <pane>` includes scrollback.
- `capture --ansi <pane>` preserves color/style escape sequences.
- `capture --path /tmp/tui.txt <pane>` writes the dump to a file.

Treat captures as the source of truth. Do not assume a key worked until the next capture shows the expected result.

## Failure Handling

- If `panes` reports `There is no active session`, first check whether the command ran inside a sandbox. If so, rerun outside the sandbox; otherwise start the agent inside Zellij or run the helper from an in-session control pane.
- If the pane exited, inspect `panes` output and relaunch the app in a fresh pane.
- If terminal size matters, resize the pane manually or create a dedicated tab/layout before testing.
- If a test needs pixel-perfect image evidence, first use text capture. Only escalate to external screenshot tooling when ANSI text is insufficient.

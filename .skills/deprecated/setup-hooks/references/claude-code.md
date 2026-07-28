# Claude Code — Hooks Reference

## Session data location

Sessions are stored as JSON files in `~/.claude/sessions/`. Each file is a single session.
History is also available at `~/.claude/history.jsonl` (one JSON object per line, newline-delimited).

For analysis, prefer `history.jsonl` for bulk scanning; fall back to individual session files for deeper inspection.

## Settings file locations

Claude Code resolves settings in order (later overrides earlier):

| Scope   | Path                                      |
|---------|-------------------------------------------|
| Global  | `~/.claude/settings.json`                 |
| Project | `<repo-root>/.claude/settings.json`       |
| Local   | `<repo-root>/.claude/settings.local.json` |

Install hooks at project scope unless they are personal workflow hooks unrelated to the repo — those belong in the global file.

## Hook lifecycle

| Event name         | Fires when                          | Can block? |
|--------------------|-------------------------------------|------------|
| `PreToolUse`       | Before any tool call executes       | Yes — exit non-zero to cancel the tool call |
| `PostToolUse`      | After a tool call completes         | No         |
| `UserPromptSubmit` | When the user submits a message     | Yes — exit non-zero to cancel submission |
| `Stop`             | When Claude finishes its response   | No         |
| `Notification`     | When a background notification fires| No         |

## Config format

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<tool-name-or-pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "<shell command>"
          }
        ]
      }
    ]
  }
}
```

- `matcher` applies only to `PreToolUse` and `PostToolUse`. Matched as a substring against the tool name (e.g. `"Edit"` matches `Edit` and `MultiEdit`). Omit for `UserPromptSubmit`, `Stop`, and `Notification`.
- Multiple matchers can be listed in the same event array.
- Multiple commands can be listed in the same `hooks` array; they run in order.

## Environment variables in hook commands

| Variable                     | Available in               | Value                               |
|------------------------------|----------------------------|-------------------------------------|
| `$CLAUDE_TOOL_NAME`          | Pre/PostToolUse            | Name of the tool being called       |
| `$CLAUDE_FILE_PATHS`         | Pre/PostToolUse (file ops) | Space-separated list of file paths  |
| `$CLAUDE_SESSION_ID`         | All                        | Current session identifier          |
| `$CLAUDE_NOTIFICATION_TITLE` | Notification               | Notification title text             |

## Common hook patterns

**Auto-format Rust files after edit:**
```json
{
  "PostToolUse": [
    {
      "matcher": "Edit",
      "hooks": [
        {
          "type": "command",
          "command": "if echo \"$CLAUDE_FILE_PATHS\" | grep -q '\\.rs$'; then rustfmt $CLAUDE_FILE_PATHS 2>/dev/null; fi"
        }
      ]
    }
  ]
}
```

**Run tests after writing a test file:**
```json
{
  "PostToolUse": [
    {
      "matcher": "Write",
      "hooks": [
        {
          "type": "command",
          "command": "if echo \"$CLAUDE_FILE_PATHS\" | grep -q '_test\\|spec'; then cargo test 2>&1 | tail -5; fi"
        }
      ]
    }
  ]
}
```

**Inject a reminder on every prompt:**
```json
{
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "echo 'Check if a built-in tool or existing CLI solves this before writing a custom script.'"
        }
      ]
    }
  ]
}
```

**Notify on session end:**
```json
{
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "notify-send 'Claude Code' 'Session complete' 2>/dev/null || true"
        }
      ]
    }
  ]
}
```

## Merging into an existing config

Read the current file, merge the `hooks` key deeply (do not overwrite sibling keys), and write back:

```bash
python3 -c "
import json, sys
path = sys.argv[1]
patch = json.loads(sys.argv[2])
with open(path) as f:
    cfg = json.load(f)
hooks = cfg.setdefault('hooks', {})
for event, entries in patch.items():
    hooks.setdefault(event, []).extend(entries)
print(json.dumps(cfg, indent=2))
" ~/.claude/settings.json '<new-hooks-json>'
```

Write the output back after confirming with the user.

## Testing hooks manually

- **PostToolUse / PreToolUse**: make a small edit to a file and check whether the hook command runs in the terminal output.
- **UserPromptSubmit**: send a short message and check whether hook output appears before Claude's response.
- **Stop**: let Claude finish a response and watch for hook output after the turn ends.

To debug, add `echo "hook fired: $CLAUDE_TOOL_NAME"` as a temporary command and remove it after confirming.

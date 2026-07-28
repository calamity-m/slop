# Codex - Hooks Reference

Source: https://developers.openai.com/codex/hooks

## Session data location

Sessions are stored under `~/.codex/sessions/`. Logs are stored under `~/.codex/log/`.

For analysis, prefer session transcripts for user/model/tool sequences and logs for runtime hook warnings.

## Settings file locations

Codex discovers hooks next to active config layers. The common locations are:

| Scope   | Path                       |
|---------|----------------------------|
| Global  | `~/.codex/config.toml`     |
| Global  | `~/.codex/hooks.json`      |
| Project | `<repo-root>/.codex/config.toml` |
| Project | `<repo-root>/.codex/hooks.json`  |

Project-local hooks load only when the project `.codex/` layer is trusted.

Prefer project scope for repo-specific checks and global scope for personal workflow hooks.
Use either `hooks.json` or inline `[hooks]` per config layer; if both exist in the same layer, Codex merges them and warns at startup.

## Feature flag

Hooks must be enabled in `config.toml`:

```toml
[features]
codex_hooks = true
```

## Hook lifecycle

| Event name          | Fires when                                | Can block? |
|---------------------|-------------------------------------------|------------|
| `SessionStart`      | A session starts, resumes, or clears      | No         |
| `PreToolUse`        | Before supported tool calls execute       | Yes, for supported deny decisions |
| `PermissionRequest` | Before Codex asks for approval            | Yes        |
| `PostToolUse`       | After supported tool calls complete       | Can replace feedback, not undo side effects |
| `UserPromptSubmit`  | Before the user prompt is submitted       | Yes        |
| `Stop`              | When Codex finishes a turn                | Can continue the turn |

## Config format

`hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "^Bash$",
        "hooks": [
          {
            "type": "command",
            "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/pre_tool_use_policy.py\"",
            "timeout": 30,
            "statusMessage": "Checking Bash command"
          }
        ]
      }
    ]
  }
}
```

Inline TOML in `config.toml`:

```toml
[features]
codex_hooks = true

[[hooks.PreToolUse]]
matcher = "^Bash$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = '/usr/bin/python3 "$(git rev-parse --show-toplevel)/.codex/hooks/pre_tool_use_policy.py"'
timeout = 30
statusMessage = "Checking Bash command"
```

Notes:

- `timeout` is in seconds. If omitted, Codex uses `600`.
- `statusMessage` is optional.
- Commands run with the session `cwd`.
- Multiple matching command hooks for the same event are launched concurrently.
- For repo-local hooks, resolve from the git root instead of using a relative `.codex/hooks/...` path. Codex may be started from a subdirectory.

## Matcher patterns

`matcher` is a regex string. Use `"*"`, `""`, or omit `matcher` to match every occurrence of a supported event.

| Event               | Matcher filters      | Notes |
|---------------------|----------------------|-------|
| `SessionStart`      | Start source         | Current values include `startup`, `resume`, and `clear` |
| `PreToolUse`        | Tool name and aliases | Supports `Bash`, `apply_patch`, and MCP tool names |
| `PermissionRequest` | Tool name and aliases | Supports `Bash`, `apply_patch`, and MCP tool names |
| `PostToolUse`       | Tool name and aliases | Supports `Bash`, `apply_patch`, and MCP tool names |
| `UserPromptSubmit`  | Not supported        | Any matcher is ignored |
| `Stop`              | Not supported        | Any matcher is ignored |

For `apply_patch`, matchers can use `apply_patch`, `Edit`, or `Write`.

## Common hook input

Every command hook receives one JSON object on stdin.

Common fields:

| Field             | Type            | Meaning |
|-------------------|-----------------|---------|
| `session_id`      | `string`        | Current session or thread id |
| `transcript_path` | `string | null` | Path to the session transcript file, if any |
| `cwd`             | `string`        | Working directory for the session |
| `hook_event_name` | `string`        | Current hook event name |
| `model`           | `string`        | Active model slug |

Tool-scoped hooks also include `turn_id`, `tool_name`, `tool_use_id`, `tool_input`, and sometimes `tool_response`.

## Common hook output

Exit `0` with no stdout is success and Codex continues.

For `SessionStart`, `UserPromptSubmit`, and `Stop`, JSON stdout can include:

```json
{
  "continue": true,
  "stopReason": "optional",
  "systemMessage": "optional",
  "suppressOutput": false
}
```

For hook-specific behavior, return `hookSpecificOutput` with the matching event name.

## Common hook patterns

**Block destructive Bash commands before execution:**

```json
{
  "PreToolUse": [
    {
      "matcher": "^Bash$",
      "hooks": [
        {
          "type": "command",
          "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/block_destructive_bash.py\"",
          "timeout": 30,
          "statusMessage": "Checking Bash command"
        }
      ]
    }
  ]
}
```

The hook script can block with:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked by hook."
  }
}
```

Codex also accepts the older block shape:

```json
{
  "decision": "block",
  "reason": "Destructive command blocked by hook."
}
```

**Allow or deny approval requests:**

```json
{
  "PermissionRequest": [
    {
      "matcher": "^Bash$",
      "hooks": [
        {
          "type": "command",
          "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/permission_request.py\"",
          "timeout": 30,
          "statusMessage": "Checking approval request"
        }
      ]
    }
  ]
}
```

To deny:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "deny",
      "message": "Blocked by repository policy."
    }
  }
}
```

To allow:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow"
    }
  }
}
```

**Inject context from a prompt hook:**

```json
{
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/user_prompt_context.py\""
        }
      ]
    }
  ]
}
```

Plain text stdout is added as extra developer context. JSON stdout can use:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Check the repo instructions before editing files."
  }
}
```

To block the prompt:

```json
{
  "decision": "block",
  "reason": "Ask for confirmation before doing that."
}
```

**Notify or continue on stop:**

```json
{
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/stop_check.py\"",
          "timeout": 30
        }
      ]
    }
  ]
}
```

`Stop` expects JSON stdout when it exits `0`; plain text is invalid for this event.
To continue the turn, return:

```json
{
  "decision": "block",
  "reason": "Run one more pass over the failing tests."
}
```

## Merging into an existing config

For `hooks.json`, read the current file, merge the `hooks` key deeply, and do not remove existing hook events:

```bash
python3 -c "
import json, sys
path = sys.argv[1]
patch = json.loads(sys.argv[2])
try:
    with open(path) as f:
        cfg = json.load(f)
except FileNotFoundError:
    cfg = {}
hooks = cfg.setdefault('hooks', {})
for event, entries in patch.items():
    hooks.setdefault(event, []).extend(entries)
print(json.dumps(cfg, indent=2))
" .codex/hooks.json '<new-hooks-json>'
```

Write the output back after confirming with the user.

For inline `config.toml`, preserve existing non-hook settings and existing hook entries. Add `[features].codex_hooks = true` if needed.

## Testing hooks manually

- **SessionStart**: start or resume a Codex session and check the hook status message or log output.
- **PreToolUse / PostToolUse**: run a small shell command or make a tiny `apply_patch` edit that matches the configured matcher.
- **PermissionRequest**: trigger a command that would normally request escalation and check whether the hook allows, denies, or defers to the normal prompt.
- **UserPromptSubmit**: send a short prompt and check whether hook-provided context or blocking behavior appears.
- **Stop**: let Codex finish a response and verify JSON-producing stop hooks in the UI or logs.

To debug, inspect `~/.codex/log/` for hook warnings. Keep `Stop` hook stdout valid JSON or empty.

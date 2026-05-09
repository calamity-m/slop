# Pi Agent — Hooks Reference

Pi does not have a separate declarative `hooks` JSON key. Hook-like behavior is implemented as TypeScript extensions that subscribe to Pi lifecycle events.

## Session data location

Sessions are stored as JSONL files under:

```text
~/.pi/agent/sessions/--<cwd-with-slashes-replaced>--/<timestamp>_<uuid>.jsonl
```

The session directory can be overridden by, in precedence order:

1. `--session-dir <dir>`
2. `PI_CODING_AGENT_SESSION_DIR`
3. `sessionDir` in settings.json

For analysis, scan `~/.pi/agent/sessions/**/*.jsonl`. Each line is a JSON object; tool calls and results are stored as session entries with message payloads.

## Settings file locations

Pi resolves JSON settings with project settings overriding global settings:

| Scope   | Path                         |
|---------|------------------------------|
| Global  | `~/.pi/agent/settings.json`  |
| Project | `<repo-root>/.pi/settings.json` |

Install workflow hooks at project scope unless they are personal workflow hooks unrelated to the repo.

## Extension file locations

Extensions are auto-discovered from:

| Scope   | Path pattern |
|---------|--------------|
| Global  | `~/.pi/agent/extensions/*.ts` |
| Global  | `~/.pi/agent/extensions/*/index.ts` |
| Project | `<repo-root>/.pi/extensions/*.ts` |
| Project | `<repo-root>/.pi/extensions/*/index.ts` |

Auto-discovered extensions can be reloaded with `/reload`. For quick tests, run:

```bash
pi -e ./.pi/extensions/my-hook.ts
```

Additional extension paths can be listed in settings:

```json
{
  "extensions": ["./extensions/my-hook.ts"]
}
```

Paths in `~/.pi/agent/settings.json` resolve relative to `~/.pi/agent`; paths in `.pi/settings.json` resolve relative to `.pi`.

## Hook lifecycle mapping

| Setup-hooks type | Pi event(s) | Can block? | Notes |
|------------------|-------------|------------|-------|
| Tool call (pre) | `tool_call` | Yes | Return `{ block: true, reason?: string }`; `event.input` is mutable. |
| Tool call (post) | `tool_result`, `tool_execution_end` | `tool_result` can modify result | Use `tool_result` for result patches; use `tool_execution_end` for observation. |
| Prompt submit | `input`, `before_agent_start` | `input` can handle/transform; `before_agent_start` can inject context | `input` sees raw text before skill/template expansion. |
| Session end | `session_shutdown`, `agent_end` | No | `session_shutdown` fires before runtime teardown; `agent_end` fires once per user prompt. |
| Session start | `session_start` | No | Fired on startup, reload, new, resume, and fork. |

Other useful events:

| Event | Use |
|-------|-----|
| `turn_start` / `turn_end` | Per LLM turn checks/checkpoints |
| `message_start` / `message_end` | Inspect or replace finalized messages (`message_end` must keep same role) |
| `session_before_switch` | Block `/new` or `/resume` |
| `session_before_fork` | Block or prepare `/fork` and `/clone` |
| `user_bash` | Intercept user `!` / `!!` commands |

## Minimal extension format

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.notify("Hook extension loaded", "info");
  });
}
```

Extensions run with full system permissions. Only install trusted code.

## Common hook patterns

**Block dangerous bash before execution:**

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (!isToolCallEventType("bash", event)) return;

    if (/\brm\s+-rf\b/.test(event.input.command)) {
      return { block: true, reason: "Blocked dangerous rm -rf command" };
    }
  });
}
```

**Auto-format Rust files after edits:**

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("tool_result", async (event, ctx) => {
    if (!["edit", "write"].includes(event.toolName)) return;
    const input = event.input as { path?: string };
    if (!input.path?.endsWith(".rs")) return;

    await pi.exec("rustfmt", [input.path]);
  });
}
```

**Inject a reminder before every agent run:**

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async () => {
    return {
      message: {
        customType: "workflow-reminder",
        content: "Check if an existing tool or CLI already solves this before writing new code.",
        display: true,
      },
    };
  });
}
```

**Notify at session shutdown:**

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_shutdown", async () => {
    await pi.exec("notify-send", ["Pi", "Session complete"]);
  });
}
```

## Installing a hook

Prefer one extension file per synthesized hook or one clearly named file for a small related group:

```text
.pi/extensions/setup-hooks/<hook-name>.ts
```

If using auto-discovery, no settings change is needed. If using a non-standard path, merge into `.pi/settings.json` without removing sibling settings:

```bash
python3 -c '
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
ext = sys.argv[2]
cfg = json.loads(path.read_text()) if path.exists() else {}
exts = cfg.setdefault("extensions", [])
if ext not in exts:
    exts.append(ext)
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(json.dumps(cfg, indent=2) + "\n")
' .pi/settings.json './extensions/setup-hooks/my-hook.ts'
```

## Testing hooks manually

- Reload extensions in an active session with `/reload`, or start Pi with `pi -e <extension.ts>`.
- **Tool call pre/post:** ask Pi to run or edit a tiny fixture that matches the hook condition.
- **Prompt submit / agent start:** send a short prompt and confirm the transformed or injected message appears.
- **Session start/end:** run `/reload`, `/new`, `/resume`, or quit Pi and watch for notification/log output.
- Add temporary `ctx.ui.notify("hook fired", "info")` or `console.log(...)` while debugging, then remove it.

## Notes for setup-hooks synthesis

- Pi built-in tool names include `bash`, `read`, `write`, and `edit` in the default coding-agent harness.
- `tool_call` sees mutable input before execution; mutating it changes the real tool call and is not revalidated.
- `tool_result` handlers can return partial patches: `{ content, details, isError }`.
- In parallel tool mode, sibling tool calls preflight sequentially but execute concurrently; do not assume a sibling result is visible during another sibling's `tool_call`.
- Use `ctx.signal` for abort-aware async work during active turns.

---
name: setup-hooks
description: "Analyze past sessions to find repeated patterns, synthesize hooks that automate them, and install those hooks for the chosen agent."
disable-model-invocation: true
---

# Setup Hooks

Analyze past sessions for recurring friction, propose hooks that address it automatically, then install them in the chosen agent.

## Step 1 — Analyze sessions

Locate the agent's session history. For each agent type, see `references/<agent>.md` for the path.

Scan sessions looking for three signals:

**1.1 Repeated pre-commit / test failures**
Look for tool outputs that include failure text followed by the same fix within the same or adjacent session. Common patterns: formatter diffs, lint errors, snapshot mismatches, whitespace stripping.

**1.2 Repeated agent actions**
Look for sequences of tool calls that appear in the same order across multiple sessions (e.g. always running `cargo fmt` after an Edit, always running tests before a commit, always reading a config file at session start).

**1.3 Repeated user messages**
Look for messages the user sends that correct the same behavior across sessions (e.g. "run the tests first", "check if the tool exists before writing one", "don't forget to tag").

Summarize what you found as a bulleted list of patterns before moving to Step 2. Do not propose hooks yet.

## Step 2 — Synthesize hook candidates

Map each pattern to a hook type. Match against the hook lifecycle available in the target agent (see reference docs):

| Hook type         | When it fires                              | Best for                                                   |
|-------------------|--------------------------------------------|------------------------------------------------------------|
| Tool call (pre)   | Before a tool executes                     | Blocking unsafe actions, injecting validation pre-edit     |
| Tool call (post)  | After a tool completes                     | Auto-format after file edits, run tests after file writes  |
| Prompt submit     | When the user sends a message              | Injecting context, appending reminders, routing            |
| Session end       | When the agent finishes responding         | Summaries, status pings, cleanup                           |
| Session start     | At the beginning of a new session          | Loading context, grepping for stale TODOs, env checks      |

For each candidate, state:
- **Trigger**: which hook type and what matcher (if applicable)
- **Command**: the shell command to run
- **Addresses**: which pattern from Step 1 it eliminates
- **Risk**: any side effect or false-positive risk

Present candidates as a numbered list. Ask the user to confirm, reject, or modify each one before proceeding.

## Step 3 — Select target agents

Ask the user which agent(s) to install hooks for. List agents you have reference docs for:

- Claude Code → `references/claude-code.md`
- Codex → `references/codex.md`
- Pi Agent → `references/pi-agent.md`

If the user names an agent without a reference doc, say so and ask them to provide config format details before continuing.

## Step 4 — Install hooks

For each confirmed hook and each selected agent:

1. Read the current settings or extension file (see reference doc for path).
2. Merge the new hook into the existing hooks config, or add/modify the extension implementing it. Do not remove existing hooks or sibling settings.
3. Write the updated config or extension.
4. Show the diff of what changed.

If the settings file does not exist and the target agent needs one, create it with only the hook-related key populated. If the target agent uses auto-discovered extension files, create only the required extension file.

## Step 5 — Verify and report

After writing:
- Confirm the settings or extension file is valid (parseable JSON, TypeScript syntax, or the agent's expected format).
- List every hook installed: trigger, matcher, command.
- Tell the user how to test each hook manually (see reference doc for agent-specific test instructions).
- Note any hooks that were skipped and why.

## References

- `references/claude-code.md` — hook lifecycle, settings.json format, matchers, test commands
- `references/codex.md` — hook lifecycle, config.toml/hooks.json format, matchers, test commands
- `references/pi-agent.md` — extension events, settings paths, session data, test commands

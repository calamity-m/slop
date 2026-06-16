---
name: learn-history
description: Analyze local agent session history for the current project and propose durable knowledge for AGENTS.md, shared skills/agents, or memory. Use when the user asks to mine past sessions, learn history, or update persistent instructions from previous work.
---

# Learn History

Mine past agent sessions for knowledge worth persisting. This skill is intentionally agent-agnostic: scan every local session source that can be safely discovered for the current repo, but keep proposed destinations portable unless the finding is provider-specific.

## Hard Rules

- **Read-only until approval.** Do not edit `AGENTS.md`, skills, agent files, or memory until the user approves the proposed changes.
- **No secrets.** Never persist tokens, private URLs, credentials, customer data, or shell history that looks sensitive. If a useful rule came from sensitive context, generalize it.
- **No duplicates.** Cross-reference existing documentation before proposing anything.
- **Prefer recurring or expensive knowledge.** One-off task details usually belong nowhere.
- **Keep instructions short.** `AGENTS.md` entries should usually be 1-2 lines. Longer operational workflows belong in a skill or agent doc.

## Discovery

1. Resolve the repo root:

   ```bash
   repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
   ```

2. Read existing persistent knowledge if present:
   - `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `.cursor/rules/*`
   - Shared skills/agents: `.agents/skills/*/SKILL.md`, `.agents/agents/*.md`
   - Provider-specific agents/prompts: `.claude/agents/*.md`, `.codex/agents/*.md`, `.pi/agent/prompts/*.md`
   - Memory files discovered under known agent homes, especially:
     - `${CLAUDE_HOME:-$HOME/.claude}/projects/$(printf '%s' "$repo_root" | tr '/' '-')/memory/MEMORY.md`
     - `${CODEX_HOME:-$HOME/.codex}/memories/MEMORY.md`
     - `${CODEX_HOME:-$HOME/.codex}/memories/memory_summary.md`
     - `${CODEX_HOME:-$HOME/.codex}/memories/raw_memories.md`

3. Discover session logs for the current repo. Start with known layouts, then add any user-specified paths:

   ```bash
   repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
   claude_key="$(printf '%s' "$repo_root" | tr '/' '-')"
   pi_key="--$(printf '%s' "$repo_root" | sed 's#/#-#g')--"

   {
     find "${CLAUDE_HOME:-$HOME/.claude}/projects/$claude_key" -maxdepth 1 -type f -name '*.jsonl' 2>/dev/null
     find "${PI_HOME:-$HOME/.pi/agent}/sessions/$pi_key" -maxdepth 1 -type f -name '*.jsonl' 2>/dev/null
     find "${CODEX_HOME:-$HOME/.codex}/sessions" -type f -name '*.jsonl' -print0 2>/dev/null |
       while IFS= read -r -d '' file; do
         jq -e --arg cwd "$repo_root" 'select(.type == "turn_context" and .payload.cwd == $cwd)' "$file" >/dev/null 2>&1 && printf '%s\n' "$file"
       done
   } | sort -u | xargs -r ls -lhS
   ```

   Only include files that are project-scoped by path or contain a `cwd`/repo marker matching `repo_root`. If a provider only has global prompt history or opaque databases, do not treat that as project history unless the user explicitly approves a broader scan. Prefer documented JSONL/session files.

## Extraction

For each session file, extract only human/assistant text. Skip tool results, tool call payloads, binary/file snapshots, and hidden reasoning when it is separable from final assistant text.

Useful `jq` patterns:

```bash
# Claude-style JSONL: top-level type=user/assistant with message.content.
jq -r '
  select(.type == "user" or .type == "assistant") |
  .type as $role |
  .message.content as $content |
  if ($content | type) == "string" then
    "\($role): \($content)"
  elif ($content | type) == "array" then
    [ $content[] | select(.type == "text") | .text ] | join("\n") as $text |
    select($text != "") | "\($role): \($text)"
  else empty end
' "$file"

# Pi-style JSONL: type=message with message.role and typed content parts.
jq -r '
  select(.type == "message") |
  .message.role as $role |
  [ .message.content[]? | select(.type == "text") | .text ] | join("\n") as $text |
  select($text != "") | "\($role): \($text)"
' "$file"

# Codex-style JSONL: response_item payloads with message content.
jq -r '
  select(.type == "response_item" and .payload.type == "message") |
  .payload.role as $role |
  [ .payload.content[]? | select(.type == "input_text" or .type == "output_text" or .type == "text") | .text ] | join("\n") as $text |
  select($text != "") | "\($role): \($text)"
' "$file"
```

If the JSON shape differs, inspect a few lines and adapt the extractor. Preserve the same principle: user text and final assistant text only.

## What To Look For

Prioritize findings with at least one of these signals:

- The user corrected or redirected the agent.
- The same fact, preference, or workflow appears in multiple sessions.
- The agent repeatedly had to rediscover a non-obvious path, command, config coupling, or project invariant.
- A failed check or bug revealed a reusable rule.
- A workflow would save substantial future exploration if documented.

Reject or put under **Nowhere** when the finding is:

- Already documented clearly.
- Too specific to a single completed task.
- Obvious from filenames, README, or standard tooling.
- Likely to become stale quickly.
- Sensitive or private unless safely generalized.

## Destination Rules

Group every candidate into exactly one destination:

- **`AGENTS.md`** — short repo-wide conventions, safety rules, verification habits, or architectural facts.
- **Shared skill/agent docs** — reusable workflows or role-specific knowledge under `.agents/skills/` or `.agents/agents/`.
- **Provider-specific docs** — only when the knowledge applies to one tool, e.g. `.claude/agents/*.md`, `.codex/*`, or `.pi/*`.
- **Memory** — durable user preferences, recurring feedback, or broad project context that should not be a repo rule.
- **Nowhere** — already covered, too narrow, stale, sensitive, or low ROI.

When uncertain between `AGENTS.md` and memory: use `AGENTS.md` for instructions every future agent in this repo must follow; use memory for user preferences or historical context that informs judgment.

## Required Output Before Editing

Present a proposal and stop for approval. Use this shape:

```markdown
## Session History Scan

Sources scanned:
- <provider/path>: <N> files, <size>, <date range>

## Proposed persistent knowledge

### AGENTS.md
- <exact proposed wording>  
  Evidence: <session/file refs and why it recurs or mattered>

### Shared skills/agents
- `<path>`: <exact proposed wording or section summary>  
  Evidence: <refs>

### Provider-specific docs
- `<path>`: <exact proposed wording or section summary>  
  Evidence: <refs>

### Memory
- <exact proposed wording>  
  Evidence: <refs>

### Nowhere
- <finding> — <why not persisted>

## Questions / approval
- <any ambiguity>
```

Do not write files until the user explicitly approves either all changes or a subset.

## Applying Approved Changes

After approval:

1. Re-read the destination files immediately before editing.
2. Apply only the approved changes, with exact minimal edits.
3. Keep `AGENTS.md` concise and avoid reshaping unrelated sections.
4. If creating or moving a shared skill/agent file, ensure any referenced relative paths exist.
5. Verify with concrete checks:
   - `git diff -- AGENTS.md .agents .claude .codex .pi`
   - syntax/format checks for any edited scripts or structured files
   - `test -e <referenced-path>` for new skill references
6. Summarize what was written and what was intentionally left out.
